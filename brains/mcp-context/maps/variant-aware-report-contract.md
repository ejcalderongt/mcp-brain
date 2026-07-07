# Variant-Aware Report Contract

Use this contract when a report needs talla/color and must stay consistent across SQL, UI, exports, and validation.

## Canonical key

If the source is variant-aware, group by:
- `codigo_producto`
- `unidad_medida`

Do not collapse variant rows back into product-only groups.

## Canonical fields to carry

Prefer to keep these fields available through the full flow:
- `empresa`
- `sucursal`
- `almacen`
- `codigo_producto`
- `descripcion`
- `unidad_medida`
- `talla`
- `color`
- `origen`
- `cantidad`
- `entrada`
- `salida`
- `inventario_final`
- `costo`
- `total_costo`

## Normalization rule

- Preserve the `TALLA - COLOR` convention.
- Allow blank color as a valid output when the source uses that convention.
- If the source is not variant-aware, keep product-only grouping instead of inventing variant rows.

## Handoff bundle for reuse

When another report needs the same logic, hand off:
1. route and UI entry point
2. controller and model names
3. source tables or mirrors
4. variant normalization rule
5. one sample product with multiple tallas

## Reuse rule

Copy this contract first, then adapt only the specific source tables and date filters for the target report.
