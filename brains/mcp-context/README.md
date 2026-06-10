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

## Última actualización operativa (2026-06-08)
- Validación de runtime en PHP 8.2.
- Habilitación de extensiones SQL Server para login (`sqlsrv`, `pdo_sqlsrv`).
- Corrección de `base_url` dinámico para evitar dependencia de nombre de carpeta (`mposbi`/`MCP`).
- Corrección de hook de autenticación para evitar loop de redirección en login.

## Seguridad
- `config/db.local.json` está excluido de git por `.gitignore`.

## Sub-Brains
- `subbrains/mpos/`: brain dedicado a Android `mpos` y correlación con MCP.
- Ruta de subagente: `subbrains/mpos/AGENT.md`.
