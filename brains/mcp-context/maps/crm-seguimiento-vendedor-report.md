# CRM Seguimiento Vendedor Report

## Change Snapshot
- Date: 2026-06-16
- Source repo: `C:\Users\yejc2\source\repos\MCP\mposbi`
- Source branch: `codex/reporte-seguimiento-vendedor`
- Source commit: `bc56da0f feat(crm): reporte seguimiento vendedor`
- Source tag: `reporte-seguimiento-vendedor-20260616`
- Pushed remote: `neworigin/codex/reporte-seguimiento-vendedor`

## Objective
Add a CRM report grouped by salesperson for a date range, consolidating commercial activity and effective documents:
- new prospects;
- contacts created;
- quotations;
- sales orders;
- BOF purchase orders tied to customer/salesperson;
- BOF certified invoices;
- new customers and existing customers with new commercial movement.

The report intentionally excludes annulled documents and uses a SQL Server stored procedure to minimize app/database roundtrips.

## Application Route Map
- Menu module: CRM (`p_modulos.idmodulo = 17`)
- Menu option: `Reporte de seguimiento de vendedor`
- Route: `reportes/seguimiento_vendedor`
- Controller: `application/controllers/reportes/Seguimiento_vendedor.php`
- Model: `application/models/reportes/Seguimiento_vendedor_model.php`
- Views:
  - `application/views/reportes/seguimiento-vendedor/cuerpo.php`
  - `application/views/reportes/seguimiento-vendedor/filtros.php`
  - `application/views/reportes/seguimiento-vendedor/lista.php`
- JavaScript: `assets/js/reportes/seguimiento-vendedor/principal.js`
- Design doc in source repo: `docs/20260616_reporte_seguimiento_vendedor_diseno.md`
- SQL deployment script: `db_changes/20260616_reporte_seguimiento_vendedor_sp_menu.sql`

## Database Contract
- Stored procedure: `dbo.sp_crm_reporte_seguimiento_vendedor`
- EC2 QA server: `EC2AMAZ-ULD1A11`
- EC2 QA database: `mpos_pollo_express_qa`

### Input Parameters
- `@codigo_empresa`
- `@fdel`
- `@fal`
- `@codigo_vendedor`
- `@codigo_sucursal`
- `@busqueda`
- `@tipo`
- `@vendedor_texto`
- `@cliente_texto`
- `@documento_texto`
- `@nit_texto`
- `@estado_texto`
- `@usuario_texto`
- `@clasificacion_texto`

### Output Columns
- `tipo_transaccion`
- `fecha_transaccion`
- `documento_id`
- `documento_numero`
- `estado_documento`
- `codigo_vendedor`
- `nombre_vendedor`
- `codigo_cliente`
- `nombre_cliente`
- `razon_social`
- `nit_cliente`
- `cliente_clasificacion`
- `simbolo_moneda`
- `monto`
- `usuario_agr`
- `nombre_usuario_agr`
- `codigo_empresa`
- `codigo_sucursal`

## Entities Consulted
- `d_prospecto`: prospect creation by salesperson/user.
- `d_prospecto_contacto`: contact creation tied to prospect.
- `d_cotizacion_enc`: quotations and sales orders.
- `d_orden_compra_bof`: BOF purchase orders tied to salesperson/customer.
- `d_venta_bof`: certified BOF invoices.
- `p_cliente`: customer identity and new/existing flags.
- `vendedores`: salesperson identity.
- `users`: `usuario_agr` / creator trace.
- `p_cotizacion_estado`: quotation/sales-order status.
- `d_orden_compra_estado_seguimiento`: purchase-order follow-up status.
- `p_moneda`: currency symbol.

## Business Rules
- Quotation: `d_cotizacion_enc.codigo_tipo_documento = 1` and `ISNULL(anulada, 0) = 0`.
- Sales order: `d_cotizacion_enc.codigo_tipo_documento = 2` and `ISNULL(anulada, 0) = 0`.
- Purchase order: `d_orden_compra_bof` with `ISNULL(anulado, 0) = 0`.
- Invoice: `d_venta_bof.certificada = 1` and `ISNULL(anulado, 0) = 0`.
- Primary attribution: group by `codigo_vendedor`.
- Operational trace: preserve creator through `usuario_agr`/`codigo_usuario` and `users.username`.

## Smart Search Context
The UI parses the intelligent search bar and maps tokens into SP parameters:
- `vendedor:` -> `@vendedor_texto`
- `cliente:` -> `@cliente_texto`
- `nit:` -> `@nit_texto`
- `doc:` / `documento:` -> `@documento_texto`
- `tipo:` -> `@tipo`
- `estado:` -> `@estado_texto`
- `usuario:` / `usr:` -> `@usuario_texto`
- `clasificacion:` -> `@clasificacion_texto`

Supported transaction aliases include:
- `cot`, `coti`, `cotizacion` -> `COTIZACION`
- `ov`, `orden_venta` -> `ORDEN_VENTA`
- `oc`, `orden_compra` -> `ORDEN_COMPRA`
- `fac`, `factura` -> `FACTURA`
- `prospecto` -> `PROSPECTO`
- `contacto` -> `CONTACTO`

## Export Contract
- Excel: backend endpoint `descargar_xls` using existing `Xls` library.
- PDF: existing report mixin `tableToPdf` over rendered HTML table.

## EC2 QA Validation Evidence
Validation date: 2026-06-16

- `Test-NetConnection 52.41.114.122:1437`: reachable.
- `sqlcmd`: connected successfully to `EC2AMAZ-ULD1A11 / mpos_pollo_express_qa`.
- Stored procedure exists: `dbo.sp_crm_reporte_seguimiento_vendedor`.
- Menu exists: `p_menuopcion.id = 165`, route `reportes/seguimiento_vendedor`.
- Menu permission roles:
  - `RoleId = 1`: `admindts`, `pvelasquez`, `rmelgar`, `axelpalala`, `apalala`.
  - `RoleId = 38`: `dtsolutions`.
- Support indexes exist:
  - `IX_d_prospecto_empresa_fecha_vendedor`
  - `IX_d_cotizacion_enc_seg_vendedor`
  - `IX_d_venta_bof_seg_vendedor`
  - `IX_d_orden_compra_bof_seg_vendedor`

### SP Smoke Test
Range: `2026-06-01` to `2026-06-16`, company `44`.

| Transaction | Count | Amount |
|---|---:|---:|
| `CONTACTO` | 26 | 0.00 |
| `COTIZACION` | 158 | 5,502,646.49 |
| `FACTURA` | 85 | 1,134,990.78 |
| `ORDEN_COMPRA` | 39 | 165,166.27 |
| `ORDEN_VENTA` | 81 | 3,016,880.24 |
| `PROSPECTO` | 40 | 0.00 |

## Regression Notes
- Do not broaden permissions with fuzzy `LIKE '%dts%'`; final script uses explicit users plus narrow name matching for Pily/Roberto/Axel and explicit `dtsolutions`.
- Keep `d_orden_compra_bof` as separate `ORDEN_COMPRA`; do not fold it into `ORDEN_VENTA`.
- The SP returns normalized rows; app-side grouping is intentionally done in Vue/PHP for report layout and export.
