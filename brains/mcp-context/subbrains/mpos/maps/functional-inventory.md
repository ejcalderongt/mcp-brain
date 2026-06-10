# Functional Inventory and Flows (MPOS)

## Tags
- `MPOS_FUNCTIONAL_MAP`
- `MPOS_INVENTARIO`
- `MPOS_VENTAS`

## Footprint Snapshot
- Manifest components (current source):
  - Activities: 187
  - Services: 11
  - Receivers: 2
- Webservice classes under `com/dtsgt/webservice`: 35

## Core Functional Domains
1. Sales and invoicing
- Main flow writes `D_FACTURA` + `D_FACTURAD` with pending sync state.
- Includes FEL branches, payments, optional order/nota-envio side effects.
- Primary files:
  - `mpos/app/src/main/java/com/dtsgt/mpos/FacturaRes.java`
  - `mpos/app/src/main/java/com/dtsgt/mpos/Venta.java`

2. Inventory movement generation
- `InvAjuste` generates `D_MOV` with `TIPO='D'`.
- `InvRecep` generates `TIPO='R'` or `TIPO='I'` depending mode.
- `InvEgreso` generates `TIPO='E'`.
- `InvCentral` generates `TIPO='R'`.
- `InvTrans` includes `TIPO='I'` header paths for transfer/staging.

Evidence:
- `mpos/app/src/main/java/com/dtsgt/mpos/InvAjuste.java:447`
- `mpos/app/src/main/java/com/dtsgt/mpos/InvRecep.java:564`
- `mpos/app/src/main/java/com/dtsgt/mpos/InvEgreso.java:391`
- `mpos/app/src/main/java/com/dtsgt/mpos/InvCentral.java:489`
- `mpos/app/src/main/java/com/dtsgt/mpos/InvTrans.java:1325`

3. Cost handling
- Inventory flows write `T_costo` and update `P_PRODUCTO.COSTO`.
- Sync layer sends `D_costo` rows and repeats product cost update SQL.

4. Sync and communication
- Centralized in `WSEnv` (push) and `WSRec` (catalog pull).
- Scheduler + network + Firebase event hooks trigger recurrence.

5. Restaurant/order/pedido ecosystem
- Extra flows for `D_orden`, mesa/sala/grupo, modifiers, printer routing.
- Mixed SOAP + HTTP path for order commit operations.

## High-Value Transaction Flows
### Flow A: Sale -> MCP
1. User confirms sale in UI.
2. App writes invoice header/detail/payment tables locally.
3. `STATCOM='N'` keeps it in pending queue.
4. `WSEnv` packages SQL delete+insert for `D_FACTURA*`.
5. SOAP `Commit` sends to backend.
6. Local status flips to sent (`S`).

### Flow B: Inventory movement -> MCP
1. Inventory module creates movement header/detail (`D_MOV`/`D_MOVD`).
2. Movement type (`TIPO`) is set by use case.
3. Sync packages movement SQL.
4. On backend success, local movement marked sent.

### Flow C: Cost update
1. Inventory operations append `T_costo` rows.
2. Product master cost is updated immediately in local DB.
3. Sync sends both historical cost row and product cost update SQL.

## MCP Correlation Touchpoints
- Sales report models consume `d_factura/d_facturad` and in several cases union with `d_venta_bof/d_ventad_bof`.
- Inventory report models consume `d_mov/d_movd` (and warehouse variants).

See:
- `subbrains/mpos/maps/fine-trace-mpos-mcp.md`
- `subbrains/mpos/maps/kardex-sales-impact.md`
