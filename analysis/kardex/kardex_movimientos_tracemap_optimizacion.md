# Trace Fino - Tablero Kardex Movimientos

## 1) Flujo de generacion actual
- Ruta UI: `/index.php/reportes/kardex_movimientos`
- Controlador: `application/controllers/reportes/Kardex_movimientos.php`
- Modelo: `application/models/reportes/Kardex_movimientos_model.php`
- Frontend: `assets/js/reportes/kardex-movimientos/principal.js`

### Secuencia
1. `index()` renderiza `cuerpo + filtros + lista`.
2. Vue `created()` dispara `getCatalogo(...)` y luego `buscar()`.
3. `buscar()` ejecuta `GET reportes/kardex_movimientos/buscar`.
4. `buscar()` en backend invoca `Kardex_movimientos_model->buscar($_GET)`.
5. Modelo ejecuta SQL CTE + window function y luego calcula indicadores/graficas en PHP.
6. Respuesta JSON retorna `lista`, `indicadores`, `graficas`, `tiempo`.

## 2) Donde se pierde tiempo
- Construccion SQL grande por request (plan reuse limitado al ir como string dinamico).
- `build_indicadores()` y `build_graficas()` recorren toda la lista en PHP.
- Exportes (`descargar_xls`, `descargar_pdf`) recalculan todo otra vez.
- Sin paginacion explicita en SQL (depende de `getConsulta`), se puede arrastrar dataset grande.

## 3) Roundtrips actuales
- Dashboard principal: 1 roundtrip para data principal + N roundtrips para catalogos (`getCatalogo`).
- Exportes: cada export repite 1 roundtrip pesado.

## 4) Estrategia de optimizacion con SP
- Crear SP empaquetado con multi-resultsets:
  - RS1: lista paginada.
  - RS2: indicadores agregados.
  - RS3: serie por dia.
  - RS4: top productos.
- Resultado: el controlador consume todo en 1 llamada SQL, sin agregaciones en PHP.

## 5) Artefacto generado
- `db_changes/20260610_sp_rpt_kardex_movimientos_pack.sql`

## 6) Indices sugeridos para soportar el SP
- `d_mov`: `(fecha, anulado, tipo, ruta)` INCLUDE `(corel)`
- `d_movd`: `(corel, producto)` INCLUDE `(cant, precio, motivo_ajuste)`
- `d_factura`: `(fecha, anulado, ruta, empresa)` INCLUDE `(corel)`
- `d_facturad`: `(corel, producto, anulado)` INCLUDE `(cant)`
- `p_empresa_usuario`: `(codigo_usuario, codigo_empresa)`
- `p_producto`: `(codigo_producto, empresa, linea)` INCLUDE `(codigo, desclarga, costo)`

## 7) Migracion backend recomendada (sin romper)
1. Mantener endpoint `buscar` igual.
2. Reemplazar `get_lista + build_*` por `EXEC dbo.sp_rpt_kardex_movimientos_pack ...`.
3. Parsear 4 resultsets y mapear al mismo JSON actual.
4. Reusar payload en exportes para evitar recalculo duplicado.

## 8) Estado validacion URL local
- Fecha validacion: 2026-06-10
- `http://127.0.0.1:8080/index.php/reportes/kardex_movimientos` no respondio dentro de 10s (timeout).
- El proceso PHP si esta escuchando en puerto 8080, por lo que el cuello apunta a bootstrap/DB/consulta bloqueada.
