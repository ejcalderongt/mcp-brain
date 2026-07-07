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
- La continuidad de contexto se conserva en `memory/YYYY-MM-DD.md` y en los mapas del brain antes de cualquier push.
- El remote operativo para este brain es `neworigin`; si aparece `origin` viejo, no asumir que sigue vigente.
- Cuando un hallazgo afecte `mpos`/`factura_mpos`, registrar usuario, rol, empresa, SQL, commit/tag y remote antes de cerrar el turno.

## Handoff reusable
- Usa `maps/project-navigation-playbook.md` antes de buscar código para ubicar repo, módulo y flujo.
- Usa `maps/variant-aware-report-contract.md` cuando un reporte necesite talla/color o lógica de variantes.

## Subagentes
- `subbrains/mpos/AGENT.md`: traza fina Android `mpos` -> MCP (WS, sync, tablas, Kardex/reportes).
- `subbrains/printagent/AGENT.md`: traza fina del driver local de impresión (facturas, tickets y futura capa de etiquetas).
