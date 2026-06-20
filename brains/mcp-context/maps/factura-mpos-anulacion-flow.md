# Factura mPos Anulacion Centralizada

## Tags
- `EJC20260620_FACTURA_MPOS`
- `MPOS_FACTURA`
- `MPOS_ANULACION`
- `D_FACTURA_MPOS_ANULACION`
- `VENTA_PERMISO_3`

## Purpose
Document the MCP-side surface that lists and annuls mPos invoices without mixing them with the standard BOF invoice flow.

## New Web Surface
- Controller: `application/controllers/venta/Factura_mpos.php`
- Model: `application/models/venta/Factura_mpos_model.php`
- Views:
  - `application/views/venta/factura_mpos/*`
- JS:
  - `assets/js/venta/factura_mpos.js`

## Route And Permission
- Route: `venta/factura_mpos`
- Annul permission: `verPermisoModulo("venta", 3)`
- The UI only exposes annul when the permission is present.

## Menu Visibility Trace
- Sidebar visibility is controlled by the permitted module/menu chain:
  - `p_modulos_rol`
  - `p_menuopcion_rol`
  - `userRoles`
- For company `80`, the operational admin validated in QA is `adminimno`:
  - `USERID = 297`
  - `RoleId = 15`
- The menu entry `Facturas mPos` (`menu_id = 167`) becomes visible only after enabling:
  - `p_modulos_rol (MODULO_ID = 14, ROL_ID = 15, ACTIVO = 1)`
  - `p_menuopcion_rol (MENUOPCION_ID = 167, MODULO_ROL_ID = 379, ACTIVO = 1)`
- Without the module-role row, the option can exist in BD but still not render in the sidebar.

## Operational Contract
1. The list reads from `D_FACTURA` as the canonical header table.
2. Search is designed for high-volume operational use and can filter by:
   - correlativo mPos
   - serie / numero
   - FEL serie / FEL numero / UUID
   - NIT and client name
   - vendedor
   - caja / ruta
   - payment description
3. The annul action marks:
   - `D_FACTURA.ANULADO = 1`
   - `D_FACTURA.RAZON_ANULACION = ...`
   - `D_FACTURAD.ANULADO = 1`
   - `D_FACTURAP.ANULADO = 1`
4. If the optional table exists, the flow also writes:
   - `D_FACTURA_MPOS_ANULACION`

## Synchronization Contract
- Endpoint for downstream sync:
  - `venta/factura_mpos/anulaciones_pendientes`
- Expected filters:
  - `empresa`
  - `ruta`
  - `desde`
  - `limite`
- The sync source of truth remains `D_FACTURA.ANULADO`, while the optional bitacora table adds timestamp and sync tracking.

## Optional Support Table
- Idempotent setup script:
  - `docs/venta/factura_mpos_setup.sql`
- Purpose:
  - create `D_FACTURA_MPOS_ANULACION`
  - create sync index
  - register the menu entry
  - copy menu-role visibility from the existing venta entry

## Implementation Notes
- The listing uses a bounded limit and keeps the UI fast by defaulting to recent data and explicit filters.
- `Razon de anulacion` is required for the annul transaction.
- The dedicated route keeps the new flow isolated from the standard factura list so BOF/MCP operations do not blur together.
