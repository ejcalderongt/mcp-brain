# Inventory Adjustment Variant Flow

## Tags
- `INVENTORY_ADJUST_VARIANT`
- `TALLA_COLOR`
- `FIREBASE_STOCK_TREE`
- `DRY_RUN_ROLLBACK`
- `EMERGENCY_ADJUSTMENT`

## Purpose
Document the reusable implementation pattern for the new MCP web inventory adjustment screen that supports talla/color variants without mixing it with the legacy generic adjustment flow.

## Activation Rule
- Feature flag: `p_paramext.id = 1001`
- Company `80` currently uses `VALOR = 'S'`
- When the flag is enabled, `inventario/ajuste` redirects to `inventario/ajuste_talla_color`
- Legacy escape hatch: `inventario/ajuste?legacy=1`

## New Web Surface
- Controller: `application/controllers/inventario/Ajuste_talla_color.php`
- Model: `application/models/inventario/Ajuste_talla_color_model.php`
- Views:
  - `application/views/inventario/ajuste_talla_color/*`
- JS:
  - `assets/js/inventario/ajuste_talla_color.js`
  - `assets/js/inventario/ajuste_talla_color_resumen.js`

## Data Flow
1. User selects warehouse/bodega and a base product.
2. System loads the product variants from `p_producto_talla_color` + `p_producto_color`.
3. Variant label is normalized as `TALLA - COLOR`.
4. Blank color is valid and should render as `L - ` style output.
5. Each detail line persists through the same movement tables used by the legacy adjustment:
   - `d_mov`
   - `d_movd`
6. Completing the adjustment updates stock through `P_stock_model::set_producto(...)`.

## Stock Persistence Rule
- `P_stock_model::set_producto(...)` is the canonical stock writer.
- When the warehouse/sucursal has `usa_firebase = 1`, the method writes to Firebase and skips SQL unless `sinFirebase` is explicitly set.
- Firebase stock tree observed:
  - `Stock/{sucursal}`
  - existing row path: `Stock/{sucursal}/{firebaseKey}`
- Firebase row shape:
  - `bandera`
  - `cant`
  - `idalm`
  - `idprod`
  - `um`

## Dry-Run / Revert Pattern
- The new controller includes `simular()`
- `simular()` saves the header/detail inside a DB transaction
- `simular()` calls `P_stock_model::set_producto(..., sinFirebase=true)` to force SQL-path evaluation
- The transaction is rolled back at the end, so the preview is safe and reversible
- Verified output pattern:
  - preview count returned
  - no stock row remained after rollback

## Operational Details
- Company `80`
- Warehouse/bodega tested successfully:
  - `codigo_almacen = 91`
  - `NOMBRE = VENTAS`
  - `codigo_sucursal = 364`
- Valid dry-run example:
  - product `54183` with a variant returned by `variantes/54183`
  - preview showed `existencia_nueva = existencia_actual + 1`
  - rollback left `p_stock` unchanged

## Implementation Notes
- Keep request payloads as object-style JSON in the controller, not PHP arrays, because `php://input` is decoded into `stdClass`.
- Accept both `codigo_sucursal` and `CODIGO_SUCURSAL` where catalog rows are used.
- Preserve `unidadmedida` exactly as the variant label used by stock lookup.
- The printout should expose the variant label so the adjustment is auditable.
- Historical adjustments can contain `motivo_ajuste = 0`.
- Detail queries must `LEFT JOIN` the motive catalog and fall back to `Sin motivo`; otherwise older adjustments render as empty detail even though `d_movd` has rows.

## Reuse Guidance
- Use this flow for emergency adjustments that must bypass Android `mpos` but still remain consistent with the stock tree.
- Keep the legacy generic adjustment route only for non-variant items or explicit fallback.
