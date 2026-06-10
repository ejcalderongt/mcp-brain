param(
    [string]$BaseUrl = "http://127.0.0.1:8080",
    [string]$Username = "admindts",
    [string]$Password = "admincba123**",
    [string]$OutDir = ".\\artifacts\\kardex-validation",
    [string]$SessionCookie = "",
    [switch]$SkipLogin
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step([string]$msg) {
    Write-Host "[KARDEX-VALIDATION] $msg" -ForegroundColor Cyan
}

function Ensure-Dir([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Invoke-Json([string]$url, $session, [string]$cookieHeader) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $headers = @{}
        if ($cookieHeader -ne "") { $headers["Cookie"] = $cookieHeader }
        $res = Invoke-WebRequest -Uri $url -WebSession $session -Headers $headers -UseBasicParsing -Method GET -TimeoutSec 90
        $sw.Stop()
        $json = $null
        try { $json = $res.Content | ConvertFrom-Json -Depth 20 } catch {}
        return [pscustomobject]@{
            ok = $true
            status = $res.StatusCode
            ms = $sw.ElapsedMilliseconds
            body = $json
            raw = $res.Content
            error = $null
            url = $url
        }
    } catch {
        $sw.Stop()
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        return [pscustomobject]@{
            ok = $false
            status = $statusCode
            ms = $sw.ElapsedMilliseconds
            body = $null
            raw = $null
            error = $_.Exception.Message
            url = $url
        }
    }
}

Ensure-Dir $OutDir
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$runDir = Join-Path $OutDir $stamp
Ensure-Dir $runDir

$loginUrl = "$BaseUrl/index.php/sesion/login"
$searchBase = "$BaseUrl/index.php/reportes/movimientos_kardex/buscar"

Write-Step "Run dir: $runDir"
Write-Step "Base URL: $BaseUrl"

$session = $null

if (-not $SkipLogin) {
    Write-Step "GET login"
    $headers = @{}
    if ($SessionCookie -ne "") { $headers["Cookie"] = $SessionCookie }
    $null = Invoke-WebRequest -Uri $loginUrl -Headers $headers -SessionVariable session -UseBasicParsing -Method GET -TimeoutSec 45

    Write-Step "POST login"
    $form = @{
        username = $Username
        password = $Password
    }
    $loginRes = Invoke-WebRequest -Uri $loginUrl -WebSession $session -Headers $headers -UseBasicParsing -Method POST -Body $form -MaximumRedirection 5 -TimeoutSec 60
    $loginSnapshot = [pscustomobject]@{
        status = $loginRes.StatusCode
        finalUrl = $loginRes.BaseResponse.ResponseUri.AbsoluteUri
        username = $Username
        time = (Get-Date).ToString("s")
    }
    $loginSnapshot | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $runDir "login.json")

    if ($loginSnapshot.finalUrl -match "/sesion/login") {
        throw "Login no exitoso. Verifica usuario/clave, 2FA o politica de sesion. finalUrl=$($loginSnapshot.finalUrl)"
    }
}

$today = Get-Date
$from1 = $today.ToString("yyyy-MM-dd")
$to1 = $today.ToString("yyyy-MM-dd")
$from10 = $today.AddDays(-9).ToString("yyyy-MM-dd")
$to10 = $today.ToString("yyyy-MM-dd")

$cases = @(
    @{
        name = "smoke_no_query"
        params = @{
            fdel = $from1
            fal = $to1
            empresa = ""
            sucursal = ""
            linea = ""
            tipo_mov = ""
            q = ""
            debug = 1
        }
    },
    @{
        name = "query_pilsener_same_day"
        params = @{
            fdel = $from1
            fal = $to1
            empresa = ""
            sucursal = ""
            linea = ""
            tipo_mov = ""
            q = "pilsener"
            debug = 1
        }
    },
    @{
        name = "query_pilsener_10_days"
        params = @{
            fdel = $from10
            fal = $to10
            empresa = ""
            sucursal = ""
            linea = ""
            tipo_mov = ""
            q = "pilsener"
            debug = 1
        }
    },
    @{
        name = "query_field_token"
        params = @{
            fdel = $from10
            fal = $to10
            empresa = ""
            sucursal = ""
            linea = ""
            tipo_mov = ""
            q = "producto:pilsener"
            debug = 1
        }
    }
)

$results = @()
foreach ($c in $cases) {
    $name = $c.name
    $qs = ($c.params.GetEnumerator() | ForEach-Object { "{0}={1}" -f $_.Key, [System.Web.HttpUtility]::UrlEncode([string]$_.Value) }) -join "&"
    $url = "${searchBase}?${qs}"
    Write-Step "Case: $name"
    $r = Invoke-Json -url $url -session $session -cookieHeader $SessionCookie

    $record = [pscustomobject]@{
        case = $name
        ok = $r.ok
        status = $r.status
        elapsed_ms = $r.ms
        registros = if ($r.body -and $r.body.lista) { @($r.body.lista).Count } else { 0 }
        fallback_aplicado = if ($r.body) { [bool]$r.body.fallback_aplicado } else { $false }
        fallback_mensaje = if ($r.body) { [string]$r.body.fallback_mensaje } else { "" }
        error = $r.error
        url = $url
    }
    $results += $record

    $payload = [pscustomobject]@{
        request = $c.params
        result = $record
        debug = if ($r.body) { $r.body.debug } else { $null }
    }
    $payload | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 (Join-Path $runDir "$name.json")
}

$results | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $runDir "summary.csv")
$results | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $runDir "summary.json")

$md = @()
$md += "# Kardex Validation Report"
$md += ""
$md += "- Generated: $(Get-Date -Format s)"
$md += "- BaseUrl: $BaseUrl"
$md += "- RunDir: $runDir"
$md += ""
$md += "| Case | Status | ms | Registros | Fallback | Error |"
$md += "|---|---:|---:|---:|---|---|"
foreach ($r in $results) {
    $md += "| $($r.case) | $($r.status) | $($r.elapsed_ms) | $($r.registros) | $($r.fallback_aplicado) | $($r.error) |"
}
$md -join "`r`n" | Set-Content -Encoding UTF8 (Join-Path $runDir "summary.md")

Write-Step "Done. Open: $runDir"
Write-Host ($results | Format-Table -AutoSize | Out-String)
