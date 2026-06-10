# Future Brain Ingestion Plan

## Objective
Keep `mcp-db-brain` continuously useful for impact analysis and change safety.

## Recurring Pipeline
1. Refresh schema snapshot:
   - `Build-DbBrain.ps1`
2. Refresh code maps:
   - regenerate module counts + code table references.
3. Build delta report against prior snapshot:
   - new/removed tables, FK changes, proc signature drift.
4. Publish consolidated index markdown for agent consumption.

## Recommended New Artifacts
- `maps/code-db-crosswalk.md`: module -> tables/views/procedures.
- `maps/runtime-config-map.md`: env files, secrets sources, feature flags.
- `maps/endpoint-catalog.md`: controller method -> route -> model dependencies.
- `maps/risk-register.md`: known hotspots, fragile joins, security debts.
- `subbrains/mpos/maps/fine-trace-mpos-mcp.md`: Android `mpos` -> MCP lineage and sync trace.
- `subbrains/mpos/maps/kardex-sales-impact.md`: impact model for Kardex and costo/margen reports.

## Governance
- Keep secrets local only (`config/db.local.json`).
- Commit only maps and generated non-sensitive metadata.
- Tag each refresh with date/time and DB name in `output/summary.md`.
