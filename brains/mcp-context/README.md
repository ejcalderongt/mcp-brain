# MCP Context Brain Repo

Repositorio dedicado para conservar y evolucionar:
- atlas técnico del proyecto,
- mapas de arquitectura/módulos/seguridad,
- herramientas de conexión y mapeo SQL,
- snapshots de metadata no sensible para agentes.

## Contenido principal
- `maps/`: trazas finas, mapas y planes de ingestión.
- `scripts/`: utilidades de conexión/query/build brain.
- `output/`: metadata generada de esquema (sin credenciales).
- `README.md` y `AGENT.md`: guía operativa del agente.
- `maps/runtime-deployment-profile.md`: perfil estable del server de producción y contexto de deploy.
- `maps/factura-mpos-anulacion-flow.md`: flujo de listado, permisos y anulación centralizada de mPos.
- `maps/role-permission-trace.md`: trazabilidad de rol, módulo y visibilidad de menú para mPos.

## Última actualización operativa (2026-06-08)
- Validación de runtime en PHP 8.2.
- Habilitación de extensiones SQL Server para login (`sqlsrv`, `pdo_sqlsrv`).
- Corrección de `base_url` dinámico para evitar dependencia de nombre de carpeta (`mposbi`/`MCP`).
- Corrección de hook de autenticación para evitar loop de redirección en login.

## Última actualización CRM/reportes (2026-06-16)
- Nuevo reporte CRM `reportes/seguimiento_vendedor`.
- SP EC2 QA `dbo.sp_crm_reporte_seguimiento_vendedor` validado en `EC2AMAZ-ULD1A11 / mpos_pollo_express_qa`.
- Mapa operativo: `maps/crm-seguimiento-vendedor-report.md`.

## Última actualización ventas mPos (2026-06-20)
- Nueva pantalla `venta/factura_mpos` para listar y anular facturas mPos sin mezclar el flujo BOF actual.
- La anulación centralizada actualiza `D_FACTURA`, `D_FACTURAD`, `D_FACTURAP` y, si existe, `D_FACTURA_MPOS_ANULACION`.
- La visibilidad del menú depende de la cadena `p_modulos_rol -> p_menuopcion_rol`; para empresa 80 se habilitó el módulo `14` (`Inventario`) para el rol `15` y con eso aparece `Facturas mPos`.
- El admin operativo validado para empresa 80 fue `adminimno` (`USERID = 297`, `RoleId = 15`).
- Mapa operativo: `maps/factura-mpos-anulacion-flow.md`.

## Seguridad
- `config/db.local.json` está excluido de git por `.gitignore`.

## Sub-Brains
- `subbrains/mpos/`: brain dedicado a Android `mpos` y correlación con MCP.
- Ruta de subagente: `subbrains/mpos/AGENT.md`.
