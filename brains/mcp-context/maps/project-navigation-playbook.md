# MCP Project Navigation Playbook

## Purpose

This playbook helps an agent orient in MCP before touching code. Use it to identify the correct repo, branch, brain map, owning module, tables, and validation path quickly.

## Standard starting point

1. Read the core brain maps first:
   - `maps/fine-trace-code-vs-db.md`
   - `maps/architecture-map.md`
   - `maps/module-map.md`
   - `maps/security-map.md`
   - `output/summary.md`
2. Then inspect the route-specific controller, model, view, and JS files.
3. Only load DB/output crosswalks or subbrains if the flow depends on the database, Firebase, SQLite, or mobile sync.

## Orientation rules

- If the route is known, do not start with broad raw searches.
- Trace in this order: route -> controller -> model -> SQL/DB tables -> cache/Firebase/SQLite -> view/JS -> export/print.
- Keep the source of truth explicit: repo, branch, and the owning module.
- Treat mirror data and raw source data separately.

## Handoff fields for another agent

Always include:
- repo and branch
- route and owning files
- main tables/views/procedures/functions
- feature flags, roles, company filters, or variant rules
- validation path
- known risks or drift points

## Variant-aware report rule

When a report needs talla/color or any other stock variant:
- keep the same grouping key through query, aggregation, export, and UI
- prefer `codigo_producto + unidad_medida`
- derive `talla` and `color` as display fields from the variant label
- reuse the variant-aware report contract instead of rediscovering the flow
