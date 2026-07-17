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

## Reusable comparison harness

When a report must be checked against another ledger-style report:
- Compare by `codigo_producto + unidad_medida` when the source is variant-aware.
- Keep `talla` and `color` as normalized presentation fields only.
- If the target ledger loses variant labels, capture that as a mismatch instead of collapsing rows silently.
- For MCP Kardex, the reusable local validator now lives in:
  - `C:\Users\yejc2\source\repos\MCP\mposbi\scripts\Validate-DetalleExistenciasVsKardex.ps1`

Interpretation rule for the validator:
- A final-quantity match with row-count mismatch usually means one side is collapsing or omitting an opening balance / corte dimension.
- A variant that appears only with negative saldo in Kardex and not in `detalle_existencias` is usually a coverage gap, not a null-helper bug.
- For reconciliation work, use the validator as a triage tool first; then decide whether the fix belongs in the ledger, the existence report, or in the new `ultimo inventario` field.

Suggested sample codes for regression:
- `9253`
- `9254`
- `9311`
- `9345`
- `9391`

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
