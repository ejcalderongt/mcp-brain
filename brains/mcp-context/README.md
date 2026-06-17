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

## Última actualización operativa (2026-06-08)
- Validación de runtime en PHP 8.2.
- Habilitación de extensiones SQL Server para login (`sqlsrv`, `pdo_sqlsrv`).
- Corrección de `base_url` dinámico para evitar dependencia de nombre de carpeta (`mposbi`/`MCP`).
- Corrección de hook de autenticación para evitar loop de redirección en login.

## Última actualización CRM/reportes (2026-06-16)
- Nuevo reporte CRM `reportes/seguimiento_vendedor`.
- SP EC2 QA `dbo.sp_crm_reporte_seguimiento_vendedor` validado en `EC2AMAZ-ULD1A11 / mpos_pollo_express_qa`.
- Mapa operativo: `maps/crm-seguimiento-vendedor-report.md`.

## Seguridad
- `config/db.local.json` está excluido de git por `.gitignore`.

## Sub-Brains
- `subbrains/mpos/`: brain dedicado a Android `mpos` y correlación con MCP.
- Ruta de subagente: `subbrains/mpos/AGENT.md`.
