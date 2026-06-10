# MPOS Sub-Brain

## Objective
Dedicated technical brain for Android `mpos` and its end-to-end correlation with MCP (`mcp-azure`) for:
- integration trace (`mpos` -> MCP DB/API),
- synchronization mechanics (SOAP/HTTP, queues, state flags),
- inventory and sales movement lineage,
- impact analysis for Kardex and management reports.

## Subagent Route
- `mcp-context-brain/subbrains/mpos/AGENT.md`

## Tags
- `MPOS_SYNC`
- `MPOS_WS`
- `MPOS_DB_LINEAGE`
- `KARDEX_DESIGN`
- `SALES_COST_GAP`

## Documents
- `maps/fine-trace-mpos-mcp.md`: complete source-to-target trace.
- `maps/ws-method-inventory.md`: SOAP/HTTP endpoint and method inventory.
- `maps/sync-orchestration-map.md`: scheduler + callback + `STATCOM` lifecycle.
- `maps/functional-inventory.md`: functional map of app flows and modules.
- `maps/kardex-sales-impact.md`: findings and recommendations for Kardex/sales reports.
- `AGENT-SKILL-MAP.md`: required/recommended skills and agent execution order.

## Scope Notes
- This sub-brain is documentation-first and non-invasive.
- No runtime behavior was changed in `mpos` or `mcp-azure`.
