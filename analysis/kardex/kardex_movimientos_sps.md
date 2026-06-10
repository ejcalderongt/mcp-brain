# Kardex Movimientos - Catalogo de SPs (Fallback Safe)

Fecha: 2026-06-10

## Objetivo
Documentar SPs para optimizacion de carga del tablero kardex, manteniendo fallback a logica legacy en PHP para no romper operacion.

## SPs
1. `db_changes/20260610_sp_rpt_kardex_movimientos_pack.sql`
- SP principal.
- Devuelve 4 resultsets en una sola ejecucion:
  - lista paginada
  - indicadores
  - serie por dia
  - top productos
- Uso desde backend: `EXEC dbo.sp_rpt_kardex_movimientos_pack ...`

2. `db_changes/20260610_sp_rpt_kardex_movimientos_lista.sql`
- Wrapper de compatibilidad para entornos que quieran invocar endpoint especifico de lista.
- Reusa `sp_rpt_kardex_movimientos_pack`.

3. `db_changes/20260610_sp_rpt_kardex_movimientos_indicadores.sql`
- Wrapper de compatibilidad orientado a consumidores de indicadores.
- Reusa `sp_rpt_kardex_movimientos_pack`.

4. `db_changes/20260610_sp_rpt_kardex_movimientos_graficas.sql`
- Wrapper de compatibilidad orientado a consumidores de graficas.
- Reusa `sp_rpt_kardex_movimientos_pack`.

## Fallback implementado en codigo
Archivo: `application/models/reportes/Kardex_movimientos_model.php`

- Flujo actual de `buscar($args)`:
  1. Intenta ejecutar `sp_rpt_kardex_movimientos_pack` via `sqlsrv` y leer multi-resultset.
  2. Si falla por cualquier razon (SP no existe, driver no disponible, error SQL), cae automaticamente a `get_lista_legacy()` + agregaciones PHP.

Esto garantiza continuidad operativa sin romper vistas ni exportes.

## Mapeo fino contra codigo

### Backend
- `application/controllers/reportes/Kardex_movimientos.php`
  - `buscar()` -> llama `Kardex_movimientos_model->buscar($_GET)` y retorna JSON.
  - `descargar_xls()` y `descargar_pdf()` -> consumen el mismo `buscar($_GET)` para evitar drift funcional.

- `application/models/reportes/Kardex_movimientos_model.php`
  - `buscar($args)`:
    - Primario: `get_pack_sp($args)` (SP).
    - Fallback: `get_lista_legacy($args)` + `build_indicadores()` + `build_graficas()`.
  - `get_pack_sp($args)`:
    - Ejecuta `EXEC dbo.sp_rpt_kardex_movimientos_pack ...`
    - Parsea resultsets:
      1. `lista` (detalle paginado)
      2. `indicadores`
      3. `graficas.movimientos_por_dia`
      4. `graficas.top_productos`
    - Si faltan datos en RS2/RS3/RS4, completa con cálculo PHP local.

### Frontend
- `assets/js/reportes/kardex-movimientos/principal.js`
  - `buscar()` consume `r.data.lista`, `r.data.indicadores`, `r.data.graficas`.
  - Contrato JSON no cambió, por eso no requiere cambios de UI.

## Estado de ejecucion en QA (2026-06-10)
- Base: `mpos_pollo_express_qa`
- SPs presentes:
  - `sp_rpt_kardex_movimientos_pack`
  - `sp_rpt_kardex_movimientos_lista`
  - `sp_rpt_kardex_movimientos_indicadores`
  - `sp_rpt_kardex_movimientos_graficas`
- Prueba directa de `sp_rpt_kardex_movimientos_pack`: OK (4 resultsets devueltos).

## Orden recomendado de despliegue
1. Ejecutar primero `20260610_sp_rpt_kardex_movimientos_pack.sql`.
2. Ejecutar wrappers `lista/indicadores/graficas`.
3. Validar endpoint: `http://127.0.0.1:8080/index.php/reportes/kardex_movimientos`.

## Rollback funcional
- No requiere rollback de codigo para estabilizar: el fallback legacy ya esta activo.
- Si un SP falla, el modulo sigue funcionando con consulta previa.
