# Project Atlas (MCP PHP)

## Stack
- Framework: CodeIgniter 3 (estructura `application/`, `system/`).
- Language: PHP.
- DB target: SQL Server (`sqlsrv`).
- Dependency manager: Composer (`composer.json`).

## Domain Surface (scan)
- Controllers: 205
- Models: 238
- Views: 753
- Helpers: 11
- Libraries: 15

## Top Module Families
- `application/controllers/reportes/*`
- `application/controllers/inventario/*`
- `application/controllers/producto/*`
- `application/controllers/mnt/*`
- `application/models/reportes/*`
- `application/models/inventario/*`
- `application/models/producto/*`

## Runtime readiness (local machine)
- `sqlcmd`: disponible.
- `php`: no detectado en PATH.
- `composer`: no detectado en PATH.

## Related Source Systems
- Android app source linked to MCP operations:
  - `C:\Users\yejc2\StudioProjects\mpos`
- Dedicated integration brain:
  - `subbrains/mpos/README.md`

## Recent CRM Reporting Artifact
- `maps/crm-seguimiento-vendedor-report.md`
- Source route: `reportes/seguimiento_vendedor`
- SQL contract: `dbo.sp_crm_reporte_seguimiento_vendedor`
- EC2 QA: `EC2AMAZ-ULD1A11 / mpos_pollo_express_qa`

## Runtime Deployment Profile
- `maps/runtime-deployment-profile.md`
- Production host sample: `EC2AMAZ-ULD1A11`
- Published MCP site: `C:\inetpub\wwwroot\mposbi`
