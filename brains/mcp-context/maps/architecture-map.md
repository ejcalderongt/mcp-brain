# Architecture Map

```mermaid
flowchart LR
  U[User Browser] --> R[CodeIgniter Router]
  R --> H[Hook Inicio::validar]
  H -->|Session| C[Controller]
  H -->|Authorization token| S[Sesion_model]
  S --> DB[(SQL Server)]
  C --> M[Model Layer]
  M --> DB
  C --> V[PHP Views + Vue Components]
  V --> U
```

## Notes
- Hook mediation is central to access decisions.
- Most business logic terminates in CI models using SQL Server.
- Frontend is hybrid SSR + Vue.
- Route handling must not assume fixed folder depth (`mposbi`); runtime now depends on dynamic base URL + resilient controller parsing.

## MPOS Integration (Sub-Brain)
```mermaid
flowchart LR
  M["Android mpos (SQLite)"] -->|"SOAP Commit(SQL)"| WS["MPosWS .asmx"]
  M -->|"HTTP /api/Orden/Commit"| API["MCP API"]
  WS --> DB[(SQL Server)]
  API --> DB
  DB --> R["MCP reportes (CI models)"]
```

- Detailed trace and evidence: `subbrains/mpos/maps/fine-trace-mpos-mcp.md`.
