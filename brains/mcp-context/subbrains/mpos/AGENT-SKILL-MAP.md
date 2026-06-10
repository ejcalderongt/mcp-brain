# Agent and Skill Map (MPOS Sub-Brain)

## Primary Agent Route
- `subbrains/mpos/AGENT.md`

## Required Skill Baseline
1. `mcp-context-agent`
- Load and align MCP main brain before any change proposal.
- Use first for architecture/security/regression context.

## Recommended Supporting Skills
1. `browser:control-in-app-browser`
- Validate report UI behavior and export actions after implementation.

2. `spreadsheets:Spreadsheets`
- Validate Excel structure/format quality for management reporting output.

3. `documents:documents`
- Build formal managerial documentation artifacts when needed.

## Optional Operational Tools
- SQL metadata scripts from `mcp-context-brain/scripts` for schema confirmation.
- `rg`-based static trace on both repos:
  - `C:\Users\yejc2\source\repos\MCP\mcp-azure`
  - `C:\Users\yejc2\StudioProjects\mpos`

## Skill Usage Rule
Always execute this sequence for risky/report-impact changes:
1. Load main context (`mcp-context-agent`).
2. Load `subbrains/mpos` traces.
3. Validate menu/permission impact.
4. Validate report cost implications (`kardex-sales-impact.md`).
