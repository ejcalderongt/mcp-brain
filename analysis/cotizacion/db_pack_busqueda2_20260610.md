# Cotizaciones - DB Pack Busqueda 2.0

Fecha: 2026-06-10
Tag: EJC20260610_COTIZACION_BUSQUEDA2_DB

## Entregables SQL generados
- `db_changes/20260610_idx_cotizacion_busqueda2.sql`
- `db_changes/20260610_sp_cotizacion_buscar_v2.sql`
- `db_changes/20260610_postcheck_cotizacion_busqueda2.sql`
- `db_changes/20260610_readme_cotizacion_busqueda2.md`

## Que mejora este paquete
- Reduce costo de filtros por empresa/sucursal/vendedor/estado/documento/fecha.
- Acelera busqueda por producto (detalle + catalogo producto).
- Deja SP v2 con soporte de tokens `key:value` y texto libre.

## Plan de rollout sugerido
1. Ejecutar en QA y medir IO/TIME.
2. Activar SP en app de forma gradual (flag por entorno).
3. Monitorear p95/p99 y locks.
4. Pasar a produccion en ventana controlada.
