# Fine Trace: Code vs DB

## Executive Snapshot
- Framework: CodeIgniter 3 (PHP monolith MVC).
- Entry point: `index.php` bootstraps CI and environment.
- DB engine inferred: SQL Server via `sqlsrv` and T-SQL patterns (`IIF`, `GETDATE`, `DATEADD`).
- Runtime DB config file: `application/config/database.php` exists in deployment but is gitignored in repo.
- Hook-based gatekeeper: `application/hooks/Inicio.php` enforces session/token access before controller logic.

## How DB Connection Is Wired
1. `application/config/autoload.php` autoloads `database` library globally.
2. CodeIgniter resolves DB params from `application/config/database.php` at runtime.
3. That file is excluded from git (`.gitignore` includes `application/config/database.php`), so credentials/environment endpoints are externalized from repository.
4. Code patterns show SQL Server-specific syntax across models, confirming `sqlsrv` driver in active environments.

## Request Flow (HTTP -> DB)
1. Browser calls route under `/index.php/<controller>/<method>`.
2. `post_controller_constructor` hook (`Inicio::validar`) runs.
3. Access path:
   - Allowed unauthenticated routes: `sesion`, `registro`, `cupon`.
   - Else if `Authorization` header exists: validates `token_api` through `Sesion_model`.
   - Else if session exists: proceeds.
   - Else redirect to login.
4. Controller executes and calls model methods.
5. Models issue query-builder SQL against SQL Server tables/views.
6. Responses are rendered as views or JSON payloads.

## Backend Architecture
- Pattern: classic CI MVC + helper-heavy shared utilities.
- Controllers coordinate request validation, orchestration, rendering.
- Models encapsulate SQL, mostly via CI Query Builder plus raw fragments.
- Helpers (`mpos_helper.php`, others) provide cross-cutting utilities and script loaders.
- Domain libraries cover invoices/FEL, Office exports, Google auth, Firebase integration.

## Frontend Architecture
- Server-side rendered PHP templates (`application/views/*`) + Vue islands.
- Two shell templates:
  - `basea.php`: legacy layout.
  - `baseb.php`: newer Xintra-based layout.
- JS stack detected:
  - Vue 2, Axios, jQuery.
  - DevExtreme (grid/gantt/diagram), DataTables, Quill.
  - SweetAlert2, Toastify, Firebase SDK (compat).
- Static assets split between `assets/` and `assets/xintra/assets/`.

## Security Trace
- Session-based authentication + optional bearer token lookup (`users.token_api`).
- 2FA available using Google Authenticator flow (`Sesion::token`).
- Password hashing in multiple paths still uses SHA1 (`sha1(...)`) rather than modern password hashing APIs.
- CSRF disabled in config (`csrf_protection = FALSE`).
- Global XSS filtering disabled (`global_xss_filtering = FALSE`).
- Cookies configured with `cookie_secure = FALSE` and `cookie_httponly = FALSE` (needs hardening in production with HTTPS).
- Session storage uses files under `application/sesion_log`.

## Operational Risks (Priority)
1. Missing repo-visible DB config hampers reproducibility without deployment secrets bundle.
2. Legacy SHA1 credential handling increases credential risk surface.
3. CSRF/XSS protection flags disabled by default.
4. Mixed legacy/new frontend shells can cause drift and duplicated dependency loading.

## Runtime Findings (2026-06-08)
- PHP 8.2 + CI3 produced deprecation noise in development; this was reduced by suppressing deprecated notices in `index.php` development mode.
- Login path was blocked by missing SQL Server extension (`sqlsrv_connect()` undefined). Resolved by enabling `sqlsrv` + `pdo_sqlsrv`.
- Routing depended on path index assumptions in `application/hooks/Inicio.php` (`$tmp[3]`) and caused redirect loops depending on folder depth (`/mposbi` vs `/MCP` vs root). Resolved with controller extraction based on real URI segments and `index.php` anchor.
- Hardcoded `base_url` to `/mposbi` caused path breakage when folder name changed. Resolved with dynamic base URL construction from host + script directory.

## Evidence Files
- `mcp-db-brain/output/summary.md`
- `mcp-db-brain/output/code_table_refs.csv`
- `mcp-db-brain/output/controller_module_counts.csv`
- `mcp-db-brain/output/model_module_counts.csv`
- `mcp-db-brain/output/view_module_counts.csv`
- `mcp-db-brain/output/db_prefix_counts.csv`

## MPOS Cross-System Extension (2026-06-09)
- New dedicated sub-brain:
  - `subbrains/mpos/README.md`
  - `subbrains/mpos/AGENT.md`
- Full trace:
  - `subbrains/mpos/maps/fine-trace-mpos-mcp.md`
- WS catalog:
  - `subbrains/mpos/maps/ws-method-inventory.md`
- Sync and queue model:
  - `subbrains/mpos/maps/sync-orchestration-map.md`
- Kardex and sales report impact:
  - `subbrains/mpos/maps/kardex-sales-impact.md`
