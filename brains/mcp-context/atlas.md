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
  - `C:\Users\yejc2\StudioProjects\mPos2026`
  - `C:\Users\yejc2\StudioProjects\mpos`  # legacy alias / historical path
- Local client-side printing driver:
  - `C:\Users\yejc2\source\repos\PrintAgent`
- Dedicated integration brain:
  - `subbrains/mpos/README.md`
  - `subbrains/printagent/README.md`

## Recent CRM Reporting Artifact
- `maps/crm-seguimiento-vendedor-report.md`
- Source route: `reportes/seguimiento_vendedor`
- SQL contract: `dbo.sp_crm_reporte_seguimiento_vendedor`
- EC2 QA: `EC2AMAZ-ULD1A11 / mpos_pollo_express_qa`

## Recent Inventory Variant Artifact
- `maps/inventory-adjustment-variant-flow.md`
- Source route: `inventario/ajuste_talla_color`
- Feature flag: `p_paramext.id = 1001`
- Stock tree note: Firebase `Stock/{sucursal}` when `p_sucursal.usa_firebase = 1`

## Recent Sales Artifact
- `maps/factura-mpos-anulacion-flow.md`
- Source route: `venta/factura_mpos`
- Permission gate: `verPermisoModulo("venta", 3)`
- Optional sync table: `D_FACTURA_MPOS_ANULACION`

## Runtime / Deploy Artifact
- `maps/runtime-deployment-profile.md`
- Production host sample: `EC2AMAZ-ULD1A11`
- Published MCP site: `C:\inetpub\wwwroot\mposbi`
- Web Deploy seed profile: `C:\Users\yejc2\Downloads\webdeploy_mposbi_ec2_ejc.PublishSettings`

## Permission / Role Artifact
- `maps/role-permission-trace.md`
- Route: `venta/factura_mpos`
- Gate: `verPermisoModulo("venta", 3)`
