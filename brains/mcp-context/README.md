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
- `maps/project-navigation-playbook.md`: primer punto de entrada para ubicar repo, módulo, tablas y validación.
- `maps/variant-aware-report-contract.md`: contrato reusable para reportes con talla/color o variantes.
- `maps/printagent-driver-trace.md`: traza del driver local de impresión cliente-side.

## Última actualización operativa (2026-06-08)
- Validación de runtime en PHP 8.2.
- Habilitación de extensiones SQL Server para login (`sqlsrv`, `pdo_sqlsrv`).
- Corrección de `base_url` dinámico para evitar dependencia de nombre de carpeta (`mposbi`/`MCP`).
- Corrección de hook de autenticación para evitar loop de redirección en login.

## Última actualización CRM/reportes (2026-06-16)
- Nuevo reporte CRM `reportes/seguimiento_vendedor`.
- SP EC2 QA `dbo.sp_crm_reporte_seguimiento_vendedor` validado en `EC2AMAZ-ULD1A11 / mpos_pollo_express_qa`.
- Mapa operativo: `maps/crm-seguimiento-vendedor-report.md`.

## Última actualización inventario variante (2026-06-20)
- Nueva pantalla `inventario/ajuste_talla_color` para ajustes de talla/color con dry-run reversible.
- Activación por `p_paramext.id = 1001` y fallback legacy `inventario/ajuste?legacy=1`.
- Mapa operativo: `maps/inventory-adjustment-variant-flow.md`.

## Última actualización ventas mPos (2026-06-20)
- Nueva pantalla `venta/factura_mpos` para listar y anular facturas mPos sin mezclar el flujo BOF actual.
- La anulación centralizada actualiza `D_FACTURA`, `D_FACTURAD`, `D_FACTURAP` y, si existe, `D_FACTURA_MPOS_ANULACION`.
- La visibilidad del menú depende de la cadena `p_modulos_rol -> p_menuopcion_rol`; para empresa 80 se habilitó el módulo `14` (`Inventario`) para el rol `15` y con eso aparece `Facturas mPos`.
- El admin operativo validado para empresa 80 fue `adminimno` (`USERID = 297`, `RoleId = 15`).
- Mapa operativo: `maps/factura-mpos-anulacion-flow.md`.

## Seguridad
- `config/db.local.json` está excluido de git por `.gitignore`.

## Regla de continuidad
- Este brain es la fuente de verdad para los hallazgos persistentes de MCP y mPos.
- El remote vigente para publicar este trabajo es `origin`; si aparece un alias viejo o una réplica paralela, no asumir que sigue vigente.
- Antes de empujar cambios importantes, registrar el resumen en `memory/YYYY-MM-DD.md` y en los mapas/AGENT del brain para no perder contexto tras una compacción.
- Para hallazgos de `venta/factura_mpos`, conservar siempre usuario, rol, empresa, SQL aplicado, commit/tag y remote usado.

## Sub-Brains
- `subbrains/mpos/`: brain dedicado a Android `mpos` y correlación con MCP.
- Ruta de subagente: `subbrains/mpos/AGENT.md`.
- `subbrains/printagent/`: brain dedicado al driver local de impresión cliente-side.
- Ruta de subagente: `subbrains/printagent/AGENT.md`.
- Federacion raiz: `C:\Users\yejc2\source\repos\MCP\federation.yml`.
- Brain overlay ligero: `C:\Users\yejc2\source\repos\MCP\brain\`.
