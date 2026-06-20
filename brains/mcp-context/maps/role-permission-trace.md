# Role Permission Trace #EJC20260620

## What We Confirmed
- MCP menu visibility is driven by the role-to-module and role-to-menu-option chain:
  - `p_modulos_rol`
  - `p_menuopcion_rol`
  - `userRoles`
- The role maintenance screen is real and already implemented:
  - controller: `application/controllers/mnt/Rol.php`
  - menu view: `application/views/mnt/rol/cuerpo.php`
  - permission editor component: `application/views/mnt/rol/permisos/cuerpo.php`
- The inventory adjustment route is already permission-based and redirects to the variant-aware screen when the feature flag is on:
  - legacy route: `inventario/ajuste`
  - variant route: `inventario/ajuste_talla_color`
- The mPos invoice cancellation surface uses the existing venta annul permission:
  - route: `venta/factura_mpos`
  - permission: `verPermisoModulo("venta", 3)`
- For company `80`, the working admin is `adminimno` (`USERID = 297`, `RoleId = 15`) and the missing piece for menu visibility was the `p_modulos_rol` row for module `14` (`Inventario`).

## Menu Targets Relevant To This Case
- `80` = `Ajuste de mercancia`
  - module: `7` (`Operaciones`)
  - controller target: `inventario/ajuste`
- `93` = `Roles y accesos`
  - module: `4` (`Mantenimientos`)
  - controller target: `mnt/rol`

## Operational Conclusion
- If the role already has modules `4` and `7`, the missing piece is usually the `p_menuopcion_rol` link, not a new controller.
- For a safe reversible enablement, use an idempotent transaction that:
  - reactivates module-role rows if needed
  - reactivates/inserts menu-option-role rows
  - rolls back in dry-run mode

## Evidence
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/controllers/mnt/Rol.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/models/mnt/P_modulos_model.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/models/mnt/P_menuopcion_model.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/models/mnt/P_menuopcion_rol_model.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/controllers/venta/Factura_mpos.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/models/venta/Factura_mpos_model.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/helpers/mpos_helper.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/views/venta/factura_mpos/cuerpo.php`
- `C:/Users/yejc2/source/repos/MCP/mposbi/application/views/venta/factura_mpos/menu.php`
