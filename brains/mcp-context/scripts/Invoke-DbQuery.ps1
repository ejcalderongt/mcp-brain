param(
  [string]$ConfigPath = "$(Join-Path $PSScriptRoot '..\config\db.local.json')",
  [string]$Query,
  [string]$QueryFile,
  [string]$OutputFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ConfigPath)) { throw "Config not found: $ConfigPath" }
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$server = "{0},{1}" -f $config.host, $config.port
$database = if ([string]::IsNullOrWhiteSpace($config.database)) { 'master' } else { $config.database }

if ($QueryFile) {
  if (-not (Test-Path $QueryFile)) { throw "Query file not found: $QueryFile" }
  $Query = Get-Content $QueryFile -Raw
}
if ([string]::IsNullOrWhiteSpace($Query)) {
  throw 'Provide -Query or -QueryFile'
}

$args = @('-S', $server, '-U', $config.username, '-P', $config.password, '-d', $database, '-y', '0', '-Y', '0', '-w', '65535', '-Q', $Query)
if ($config.encrypt) { $args += '-N' }
if ($config.trustServerCertificate) { $args += '-C' }

$result = & sqlcmd @args 2>&1
if ($LASTEXITCODE -ne 0) { throw ($result | Out-String) }

if ($OutputFile) {
  $dir = Split-Path -Parent $OutputFile
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $result | Set-Content -Path $OutputFile -Encoding UTF8
} else {
  $result
}
