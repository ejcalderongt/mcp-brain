# Module Map

## Controller Domain Weight (Top)
See `mcp-db-brain/output/controller_module_counts.csv`.

Highest-density domains inferred:
- `mnt` (master data / admin / security / catalog configuration)
- `reportes` (analytics and operational reporting)
- `crm` (prospect, cotizacion, comision)
- `producto` (catalog and product behavior)
- `servicios` (tickets/orders/service workflows)
- `inventario`, `compra`, `venta`, `cotizacion`

## View Density
See `mcp-db-brain/output/view_module_counts.csv`.

Largest UI footprints:
- `mnt`
- `reportes`
- `producto`
- `crm`
- `servicios`

This indicates strongest UI complexity and change surface in administrative and reporting areas.

## DB Domain Prefixes (Top)
See `mcp-db-brain/output/db_prefix_counts.csv`.

Dominant table families:
- `trans*` (transactional operations)
- `i_*` (integration/sync pipeline)
- `producto*`
- `stock*`
- `regla*`
- `tmp*` and `log*`

## Inferred Functional Modules
- Security & Access: users, roles, permisos, token API, 2FA.
- Master Data (MNT): empresa, sucursal, cliente/proveedor, catálogos operativos.
- Sales (venta/cotizacion/cxc): quotation, orders, invoicing, receivables.
- Purchasing (compra/cxp): order, reception, payables.
- Inventory & Logistics: stock, ajustes, traslados, envíos.
- Reporting & BI: operational and financial report suites.
- CRM: prospect lifecycle, proposals, tasks, commissions.
- Services/Ticketing: service orders, status, evidence/photo flows.
- Fiscal/E-invoicing: FEL integrations by country variants.
- Integrations: Firebase, Microsoft Graph/OAuth, email channels.

## CRM Reporting Update (2026-06-16)
- New report route: `reportes/seguimiento_vendedor`.
- Main source map: `maps/crm-seguimiento-vendedor-report.md`.
- It bridges CRM prospect/contact activity with quotation, sales order, BOF purchase order and certified invoice activity through `dbo.sp_crm_reporte_seguimiento_vendedor`.

## MPOS Related Modules (Cross-System)
- POS mobile sales: `D_FACTURA`, `D_FACTURAD` lineage.
- Mobile inventory movements: `D_MOV`, `D_MOVD`, `D_MOV_ALMACEN`, `D_MOVD_ALMACEN`.
- Cost movement stream: `T_costo` and `P_regla_costo`.
- Sync stack: `WSEnv`, `WSRec`, `srvTimerService`, `srvCommit`, `HttpCommit`.
- Full map: `subbrains/mpos/maps/functional-inventory.md`.
