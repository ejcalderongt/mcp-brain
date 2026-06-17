# Runtime Deployment Profile

## Purpose
Record the mostly stable production-server facts for the MCP site so future deploy and operations conversations can start from known context instead of re-discovering the environment every time.

## Current Production Host
- Hostname: `EC2AMAZ-ULD1A11`
- OS: `Microsoft Windows Server 2022 Datacenter`
- Architecture: `64-bit`
- PowerShell: `7.5.1` (Core edition in the collected sample)
- Local admin in the RDP session used for the sample: `True`

## Web Platform
- Web server: `IIS`
- Running IIS service: `W3SVC`
- Site names observed:
  - `Default Web Site`
  - `mposbi`
  - `MCPWebAPI`
  - `WMSWebAPI`
  - `gabolive`
  - `PODWebAPI`
  - `AssetTrack`
  - `WMSWebAPI2`
  - `POD`

## MCP Site
- Published path: `C:\inetpub\wwwroot\mposbi`
- Application folder present: `application/`
- CodeIgniter root detected: yes
- Git repository detected in published folder: no

## Tooling State
- `sqlcmd`: installed and reachable
- `php`: not available on `PATH` in the collected sample
- `ODBC Driver 17 for SQL Server`: installed for 32-bit and 64-bit

## Stable vs Volatile
- Stable enough to keep as context:
  - hostname
  - OS family/version
  - IIS as the published platform
  - published site path
  - CodeIgniter root layout
  - `sqlcmd` availability
- Volatile, do not hardcode as permanent facts:
  - private IP addresses
  - DHCP leases
  - uptime
  - current process IDs
  - current account identity from a specific RDP session

## Deploy Implication
This environment is a good candidate for controlled deploy via:
- versioned `releases/`
- `current` junction/symlink
- smoke test before switch
- fast rollback to previous release

