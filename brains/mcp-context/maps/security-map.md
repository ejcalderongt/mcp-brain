# Security Map

## AuthN / AuthZ
- Primary login: `application/controllers/Sesion.php` + `application/models/Sesion_model.php`.
- Session object key: `usuario`.
- API-like token auth through `Authorization` header (lookup against `users.token_api`) in `application/hooks/Inicio.php`.
- Route allowlist without auth: `sesion`, `registro`, `cupon`.

## Security Controls Present
- Session lifecycle handling (destroy/logout, session regeneration interval).
- Optional second factor using Google Authenticator (`Sesion::token`).
- Hook gate before business endpoints.

## Security Gaps / Legacy Debt
- SHA1 password checks in multiple flows.
- CSRF disabled.
- Global XSS filtering disabled.
- Cookie hardening flags disabled (`secure`, `httponly`).
- Some raw SQL string composition patterns increase injection risk if inputs are not sanitized upstream.
- Authentication gate in hook layer is sensitive to URI parsing; if route parsing is wrong, it can induce login redirect loops (availability risk).

## Hardening Backlog (Suggested Order)
1. Introduce `password_hash/password_verify` migration path with backward-compatible rehash-on-login.
2. Enable CSRF progressively (starting with non-API forms).
3. Turn on `cookie_httponly=true` and `cookie_secure=true` under HTTPS.
4. Audit query-builder raw fragments for unescaped interpolation.
5. Add central authorization matrix for role-route-action checks.

## MPOS Integration Security Notes
- Android app currently allows cleartext traffic (`usesCleartextTraffic=true`), which increases transport exposure on non-trusted networks.
- `mpos` sync sends SQL payloads through SOAP/HTTP commit channels, so server-side validation and endpoint ACLs are critical.
- Menu visibility for new reports is role-dependent (`p_modulos_rol`, `p_menuopcion_rol`, `userRoles`), so permission drift can expose or hide options unexpectedly.
- See detailed trace: `subbrains/mpos/maps/fine-trace-mpos-mcp.md`.
