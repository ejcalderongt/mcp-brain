# Kardex and Sales Report Impact (Based on MPOS Findings)

## Tags
- `KARDEX_READY`
- `SALES_COST_GAP`
- `MENU_PERMISSION_MODEL`
- `NO_BREAK_CHANGE`

## Findings That Affect Reporting
1. POS invoices are generated in `D_FACTURA`/`D_FACTURAD` and synced to MCP.
2. Inventory movement source of truth is `D_MOV`/`D_MOVD` (+ `D_MOV_ALMACEN` variants).
3. Current sales margins in MCP reports use `p_producto.costo` at query time, not movement-time frozen cost.
4. `mpos` records cost events in `T_costo` and pushes them (`D_costo`) while also updating `P_PRODUCTO.COSTO`.

Evidence highlights:
- POS write: `mpos/app/src/main/java/com/dtsgt/mpos/FacturaRes.java:1349`
- Movement write: `mpos/app/src/main/java/com/dtsgt/base/BaseDatosScript.java:900`
- Cost push/update: `mpos/app/src/main/java/com/dtsgt/mpos/WSEnv.java:1593`, `mpos/app/src/main/java/com/dtsgt/mpos/WSEnv.java:2105`
- MCP cost formula in report: `mcp-azure/application/models/reportes/Ventas_gerencial_detalle_model.php:125`

## Do We Need Updates in Kardex?
Yes.

Reason:
- `D_MOV/D_MOVD` already contain the transaction stream required for Kardex.
- A dedicated Kardex report does not exist yet in `application/reportes` by name.
- Current inventory reports are aggregate/summary oriented, not full chronological ledger with running balance.

## Do We Need Updates in Sales Reports?
Yes, but as controlled enhancement.

Reason:
- Current report margin uses `p_producto.costo` (current master cost) for historical sales.
- If cost changes later, old sales margins can drift.

Impact scope:
- `Ventas_gerencial_detalle_model`
- `Margen_*` and other cost-sensitive sales reports

## Kardex Report Design (No-break blueprint)
Data base:
- `d_mov` + `d_movd`
- optional union with `d_mov_almacen` + `d_movd_almacen`

Minimum columns:
- Fecha/hora, Empresa, Sucursal, Ruta/Almacen, Correlativo
- Tipo movimiento, Producto, Unidad
- Entrada, Salida, Cantidad neta
- Costo unitario movimiento (`d_movd.precio` when present)
- Valor movimiento
- Saldo cantidad acumulado
- Saldo valorizado (according to selected cost policy)

Filters:
- Empresa, Sucursal, Almacen, Producto/Familia
- Rango de fechas (mandatory)
- Tipo movimiento
- Barra de busqueda avanzada (same token model used in `Ventas_gerencial_detalle_model`)

Executive indicators:
- Entradas totales
- Salidas totales
- Ajustes netos
- Rotacion
- Costo promedio periodo

Exports:
- Excel and PDF with enriched format
- Optional chart pack: entradas vs salidas por dia, top productos movidos

## Regression sample for variant fidelity

Use this sample set when checking whether Kardex reconstructs the same variant tree as `reportes/detalle_existencias`:
- `9253`
- `9254`
- `9311`
- `9345`
- `9391`

Validation harness:
- `C:\Users\yejc2\source\repos\MCP\mposbi\scripts\Validate-DetalleExistenciasVsKardex.ps1`

What the harness guards:
- `detalle_existencias` must keep rows separated by `codigo_producto + unidad_medida`
- Kardex must not lose `unidad_medida` / `talla` / `color` when a source movement carries talla/color data
- QueryBuilder result rows can arrive as `stdClass`; common helpers must support that shape or Kardex 500s
- Filtering by company access should validate permissions without multiplying rows; prefer `EXISTS` over a permissive join when the user has multiple bridge rows

Current diagnostic note from the latest validation run (`20260717-115241`):
- `9311` and `9345` already match on final quantity.
- `9253`, `9254`, and `9391` still differ because the comparison is exposing a variant/corte gap, not because the Kardex page stopped rendering.
- For these codes, the remaining review is to decide whether the missing piece belongs in `detalle_existencias` as `ultimo inventario` or in a source-filter rule for the Kardex view.
- Keep the validator around as the repeatable proof artifact instead of re-deriving the mismatch manually.

## Cost Policy Parameterization (Model only)
Goal:
- Keep current behavior as default.
- Allow per-company policy switch without breaking production.

Recommended parameter key in `p_paramext` (MCP side):
- `id`: new agreed key
- values: `ULTIMO_COSTO` (default), `PROMEDIO_PONDERADO`

Why `p_paramext`:
- Existing report code already reads company-scoped `p_paramext` (currency example `id=12`):
  - `mcp-azure/application/models/reportes/Ventas_gerencial_detalle_model.php:139`

Safe rollout:
1. Implement Kardex first with explicit policy label and default `ULTIMO_COSTO`.
2. Introduce policy parameter read-only in report layer.
3. Later implement weighted-average calculation path, behind parameter toggle.

## Menu and Permission Model for New Report Visibility
For a new report option to be visible in MCP menu:
1. Create `p_menuopcion` entry with correct `modulo_id`, `enlace`, and active flag.
2. Grant access through `p_menuopcion_rol` linked to `modulo_rol_id`.
3. Ensure role exists/enabled in `p_modulos_rol` and linked in `userRoles`.

Evidence:
- Menu fetch endpoint: `mcp-azure/application/controllers/mnt/Menu.php:163`
- Option permission query: `mcp-azure/application/models/mnt/P_menuopcion_model.php:68`
- Role joins: `mcp-azure/application/models/mnt/P_menuopcion_model.php:94`

## Final Decision
- Kardex: implement as new report (required).
- Sales reports: update cost strategy carefully (recommended), keeping current logic default until policy toggle is enabled per company.
