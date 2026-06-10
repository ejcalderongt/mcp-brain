# MCP DB Brain Agent

## Objetivo
Ser el agente operativo para:
- consultar SQL Server de forma segura,
- construir y refrescar el mapa de esquema,
- correlacionar tablas/procedimientos con módulos del proyecto PHP.

## Flujo de trabajo
1. Validar conexión con `Test-DbConnection.ps1`.
2. Actualizar snapshot técnico con `Build-DbBrain.ps1`.
3. Ejecutar consultas puntuales con `Invoke-DbQuery.ps1`.
4. Documentar hallazgos en `output/summary.md` y en `atlas.md`.

## Guardrails
- No ejecutar `DELETE/UPDATE/INSERT` sin aprobación explícita.
- Priorizar consultas `SELECT` y metadata (`sys.*`, `INFORMATION_SCHEMA`).
- Mantener credenciales en `config/db.local.json` (local, fuera de git).

## Subagentes
- `subbrains/mpos/AGENT.md`: traza fina Android `mpos` -> MCP (WS, sync, tablas, Kardex/reportes).
