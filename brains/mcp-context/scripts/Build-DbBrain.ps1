param(
  [string]$ConfigPath = "$(Join-Path $PSScriptRoot '..\config\db.local.json')",
  [string]$OutputDir = "$(Join-Path $PSScriptRoot '..\output')"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-SqlJsonFile {
  param([Parameter(Mandatory = $true)][string]$Path)
  $raw = Get-Content $Path -Raw
  $start = $raw.IndexOf('[')
  $end = $raw.LastIndexOf(']')
  if ($start -lt 0 -or $end -lt 0 -or $end -le $start) {
    throw "Could not locate JSON payload in $Path"
  }
  $json = $raw.Substring($start, ($end - $start + 1))
  return ($json | ConvertFrom-Json)
}

$invoke = Join-Path $PSScriptRoot 'Invoke-DbQuery.ps1'
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$dbListQuery = @"
SET NOCOUNT ON;
SELECT name
FROM sys.databases
WHERE name NOT IN ('master','tempdb','model','msdb')
ORDER BY name;
"@

$dbListRaw = & $invoke -ConfigPath $ConfigPath -Query $dbListQuery
$dbs = @(
  $dbListRaw |
    ForEach-Object { $_.ToString().Trim() } |
    Where-Object {
      $_ -and
      $_ -notmatch '^[- ]+$' -and
      $_ -ne 'name' -and
      $_ -notmatch '^\(\d+\s+rows?\s+affected\)$'
    }
)

if ($dbs.Count -eq 0) { throw 'No user databases found.' }

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($config.database) -or $config.database -eq 'master') {
  $config.database = $dbs[0]
  ($config | ConvertTo-Json -Depth 5) | Set-Content -Path $ConfigPath -Encoding UTF8
}

$selectedDb = $config.database

$tablesQuery = @"
SET NOCOUNT ON;
SELECT s.name AS schema_name, t.name AS table_name, t.create_date, t.modify_date
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
ORDER BY s.name, t.name
FOR JSON PATH;
"@

$columnsQuery = @"
SET NOCOUNT ON;
SELECT sch.name AS schema_name, tab.name AS table_name, col.column_id, col.name AS column_name,
       typ.name AS data_type, col.max_length, col.precision, col.scale, col.is_nullable,
       col.is_identity
FROM sys.columns col
JOIN sys.tables tab ON col.object_id = tab.object_id
JOIN sys.schemas sch ON tab.schema_id = sch.schema_id
JOIN sys.types typ ON col.user_type_id = typ.user_type_id
ORDER BY sch.name, tab.name, col.column_id
FOR JSON PATH;
"@

$pkQuery = @"
SET NOCOUNT ON;
SELECT sch.name AS schema_name, tab.name AS table_name, kc.name AS pk_name, col.name AS column_name, ic.key_ordinal
FROM sys.key_constraints kc
JOIN sys.tables tab ON kc.parent_object_id = tab.object_id
JOIN sys.schemas sch ON tab.schema_id = sch.schema_id
JOIN sys.index_columns ic ON ic.object_id = tab.object_id AND ic.index_id = kc.unique_index_id
JOIN sys.columns col ON col.object_id = tab.object_id AND col.column_id = ic.column_id
WHERE kc.type = 'PK'
ORDER BY sch.name, tab.name, ic.key_ordinal
FOR JSON PATH;
"@

$fkQuery = @"
SET NOCOUNT ON;
SELECT fk.name AS fk_name,
       schp.name AS parent_schema, tabp.name AS parent_table, colp.name AS parent_column,
       schr.name AS ref_schema, tabr.name AS ref_table, colr.name AS ref_column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tabp ON fkc.parent_object_id = tabp.object_id
JOIN sys.schemas schp ON tabp.schema_id = schp.schema_id
JOIN sys.columns colp ON colp.object_id = tabp.object_id AND colp.column_id = fkc.parent_column_id
JOIN sys.tables tabr ON fkc.referenced_object_id = tabr.object_id
JOIN sys.schemas schr ON tabr.schema_id = schr.schema_id
JOIN sys.columns colr ON colr.object_id = tabr.object_id AND colr.column_id = fkc.referenced_column_id
ORDER BY fk.name
FOR JSON PATH;
"@

$procsQuery = @"
SET NOCOUNT ON;
SELECT sch.name AS schema_name, p.name AS procedure_name, p.create_date, p.modify_date
FROM sys.procedures p
JOIN sys.schemas sch ON p.schema_id = sch.schema_id
ORDER BY sch.name, p.name
FOR JSON PATH;
"@

$funcQuery = @"
SET NOCOUNT ON;
SELECT sch.name AS schema_name, o.name AS function_name, o.type_desc
FROM sys.objects o
JOIN sys.schemas sch ON o.schema_id = sch.schema_id
WHERE o.type IN ('FN','IF','TF')
ORDER BY sch.name, o.name
FOR JSON PATH;
"@

$viewsQuery = @"
SET NOCOUNT ON;
SELECT sch.name AS schema_name, v.name AS view_name, v.create_date, v.modify_date
FROM sys.views v
JOIN sys.schemas sch ON v.schema_id = sch.schema_id
ORDER BY sch.name, v.name
FOR JSON PATH;
"@

& $invoke -ConfigPath $ConfigPath -Query $tablesQuery -OutputFile (Join-Path $OutputDir 'tables.json')
& $invoke -ConfigPath $ConfigPath -Query $columnsQuery -OutputFile (Join-Path $OutputDir 'columns.json')
& $invoke -ConfigPath $ConfigPath -Query $pkQuery -OutputFile (Join-Path $OutputDir 'primary_keys.json')
& $invoke -ConfigPath $ConfigPath -Query $fkQuery -OutputFile (Join-Path $OutputDir 'foreign_keys.json')
& $invoke -ConfigPath $ConfigPath -Query $procsQuery -OutputFile (Join-Path $OutputDir 'procedures.json')
& $invoke -ConfigPath $ConfigPath -Query $funcQuery -OutputFile (Join-Path $OutputDir 'functions.json')
& $invoke -ConfigPath $ConfigPath -Query $viewsQuery -OutputFile (Join-Path $OutputDir 'views.json')

$tables = Read-SqlJsonFile -Path (Join-Path $OutputDir 'tables.json')
$views = Read-SqlJsonFile -Path (Join-Path $OutputDir 'views.json')
$procs = Read-SqlJsonFile -Path (Join-Path $OutputDir 'procedures.json')
$funcs = Read-SqlJsonFile -Path (Join-Path $OutputDir 'functions.json')
$summary = @"
# DB Brain Summary

- Database: $selectedDb
- Tables: $($tables.Count)
- Views: $($views.Count)
- Procedures: $($procs.Count)
- Functions: $($funcs.Count)
- Generated at: $(Get-Date -Format s)

## Files
- tables.json
- columns.json
- primary_keys.json
- foreign_keys.json
- procedures.json
- functions.json
- views.json
"@
$summary | Set-Content -Path (Join-Path $OutputDir 'summary.md') -Encoding UTF8
Write-Output "DB brain generated for database: $selectedDb"
