# DB Brain Summary

- Database: IMS4MB_INELAC_PRD
- Tables: 368
- Views: 218
- Procedures: 48
- Functions: 12
- Generated at: 2026-06-08T10:22:08

## Files
- tables.json
- columns.json
- primary_keys.json
- foreign_keys.json
- procedures.json
- functions.json
- views.json

## Runtime Findings (2026-07-29): Inventory Reports

- Detalle de existencias is the physical-closing reference for Kardex.
- One closing per `codigo_producto + unidad_normalizada`; running balances are
  not additive.
- DevExtreme filters and composite searches preserve/restrict physical closings
  by represented product IDs.
- Services are excluded; inactive products and unit mismatches are exceptions.
- Detalle limits generation to 90 days and recalculates historical range CPP.
- Company `30`, sucursal `113`, `2026-05-31..2026-07-29`:
  `5,386,750.0800` in both reports, difference `0.0000`.
- Full map: `maps/inventory-reports-kardex-detail-existence.md`.
