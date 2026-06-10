param(
  [string]$ConfigPath = "$(Join-Path $PSScriptRoot '..\config\db.local.json')"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script = Join-Path $PSScriptRoot 'Invoke-DbQuery.ps1'
& $script -ConfigPath $ConfigPath -Query "SET NOCOUNT ON; SELECT @@SERVERNAME AS server_name, DB_NAME() AS current_db, GETDATE() AS server_time;"
