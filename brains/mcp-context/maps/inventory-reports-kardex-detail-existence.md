# Reportes de inventario MCP: Kardex y Detalle de existencias

## Estado validado

- Fecha: `2026-07-29`
- Fuente: `C:\Users\yejc2\source\repos\MCP\mposbi`
- Rama: `dev2026`
- Rutas:
  - `reportes/movimientos_kardex`
  - `reportes/detalle_existencias`
- Caso integral: empresa `30`, sucursal `113`
  (`BRAUHAUS / BRAUHAUS BGZ4`).

## Contrato canónico

`Detalle de existencias` es la referencia del cierre físico. Kardex es la
explicación cronológica de los movimientos y debe cerrar contra esa referencia
para la misma empresa, sucursal y fechas.

La llave física estable es:

```text
codigo_producto + unidad_normalizada
```

En empresas con talla/color, la variante participa como unidad física. Deben
normalizarse mayúsculas, espacios y separadores antes de comparar.

Las entradas y salidas son flujos sumables. `Saldo anterior` y `Existencia` son
saldos acumulados y nunca deben sumarse entre filas. El resumen toma un solo
cierre físico por llave.

## Mapa de código

### Kardex

- Controller:
  `application/controllers/reportes/Movimientos_kardex.php`
- Model:
  `application/models/reportes/Movimientos_kardex_model.php`
- Frontend:
  `assets/js/reportes/movimientos-kardex/principal.js`
- Vistas:
  `application/views/reportes/movimientos-kardex/*`
- JSON:
  `reportes/movimientos_kardex/buscar`
- Documento:
  `reportes/movimientos_kardex/detalle_documento`

### Detalle de existencias

- Controller:
  `application/controllers/reportes/Detalle_existencias.php`
- Model:
  `application/models/reportes/Repexistencia_model.php`
- Frontend:
  `assets/js/reportes/detalle-existencias/principal.js`
- JSON:
  `reportes/detalle_existencias/buscar`

## Fuentes de inventario

- `d_mov` / `d_movd`
- `d_mov_almacen` / `d_movd_almacen`
- Ventas POS: `d_factura` / `d_facturad`
- Ventas MCP/BOF: `d_venta_bof` / `d_ventad_bof`
- Consumo de materia prima, recetas y combos.
- Reservas, envíos y cortesías cuando aplican.
- Apertura reconstruida desde el último corte válido y movimientos anteriores
  al inicio solicitado.

Los servicios (`p_producto.codigo_tipo = 'S'`) se excluyen de ambos reportes.
Detalle también limita el catálogo a productos activos.

## Fechas

- La apertura es el saldo al cierre del día anterior a `fdel`.
- Los movimientos del rango explican la transición apertura-cierre.
- Detalle permite máximo 90 días inclusivos por generación.
- Kardex requiere sucursal para evitar mezclar saldos y usa límite de ejecución
  de 120 segundos.
- El fallback de búsqueda amplía 30 días únicamente rangos cortos de 1 a 3
  días; no cambia el rango canónico de conciliación.

## Semántica de columnas

```text
existencia = saldo_anterior + entrada - salida
```

- `Inventario inicial`: apertura antes del primer movimiento del rango.
- `Saldo anterior`: existencia inmediatamente antes de la fila.
- `Entrada`: cantidad positiva que ingresa.
- `Salida`: cantidad positiva que egresa.
- `Existencia`: saldo después de aplicar la fila.

## Resumen de existencia y filtros DevExtreme

1. Resolver el cierre físico de Detalle por llave estable.
2. Reconstruir los saldos visibles para que la última fila cierre allí.
3. Marcar `existencia_cierre_resumen` una sola vez por llave.
4. El resumen custom de DevExtreme conserva el cierre de las llaves
   representadas aunque el filtro oculte la última fila.
5. Nunca sumar saldos intermedios.

El card puede representar el total canónico de Detalle aunque haya productos
sin movimientos y, por tanto, sin filas Kardex. Esa diferencia entre stock y
flujo debe explicarse al comparar card y grilla.

## Búsqueda avanzada

Kardex tokeniza búsquedas como:

```text
F14 AGUA TONICA
doc:12345
tipo:venta
sucursal:zona 10
```

Detalle usa un término simple. Enviar la frase completa a Detalle puede no
encontrar referencia y mostrar existencia cero.

Regla vigente:

1. Consultar la referencia canónica por empresa, sucursal y fechas.
2. Obtener los `codigo_producto` encontrados realmente por Kardex.
3. Restringir la referencia por esos IDs cuando hay búsqueda avanzada, producto
   o tipo de movimiento.

Publicado en `f99dafbe`.

## Detalle del documento

El link del documento debe reconstruir la transacción de origen, no solamente
mostrar el balance de la fila:

- factura/venta,
- ajuste,
- consumo,
- otro documento relacionado.

Debe conservar empresa/sucursal, quitar filtros de producto/tipo de la grilla y
mostrar todas las líneas del documento.

## Unidades, variantes e inactivos

- No mezclar empresa ni sucursal.
- Normalizar unidad antes de conciliar.
- Talla/color es dimensión física, no decoración.
- No combinar unidades sin conversión explícita.
- Una unidad histórica distinta de `p_producto.unidbas` es excepción de calidad
  de datos, no una segunda existencia física válida.
- Un producto inactivo puede conservar movimientos históricos: Detalle lo
  excluye, mientras Kardex actualmente puede mostrar el movimiento.

Excepciones trazadas:

- `67 / COCA COLA NORMAL`: producto inactivo; un consumo quedó visible solo en
  Kardex.
- `D12 / SALUTARIS TORONJA`: unidad maestra `UN`; ajuste
  `0_20260617144813` grabado en `ML` por `-4086`. El cierre canónico `UN` sí
  cuadró; `ML` es una anomalía de unidad.

## Costeo en Detalle de existencias

El costo no altera la conciliación de cantidades.

Fallback SQL:

1. Si `metodo_costo = COSTO_PROMEDIO_PONDERADO` y existe CPP válido del almacén
   antes de `fal`, usar `D_PRODUCTO_COSTO_ALMACEN`.
2. Si no, usar el último costo positivo anterior a `fal` de `d_costo` o
   `d_costo_bof`.
3. Si no, usar `p_producto.costo`.
4. Si no existe costo, marcar `SIN_COSTO`.

CPP periódico del rango:

```text
CPP =
  (cantidad_apertura * costo_apertura
   + sum(cantidad_recepción * costo_recepción))
  / (cantidad_apertura + sum(cantidad_recepción))
```

Solo participan recepciones tipo `R`, no anuladas, con cantidad y precio
positivos. El costo de apertura se busca estrictamente antes de `fdel`; nunca se
debe usar un CPP futuro para un reporte histórico. Las pantallas de ajuste
reutilizan este servicio y el mismo límite de 90 días.

Nota de implementación: `aplicarCppPeriodicoRango()` actualmente reemplaza el
costo cuando divisor y costo de apertura son positivos. Si negocio exige
compuerta estricta por `metodo_costo`, debe agregarse y probarse dentro de ese
loop; no basta el `CASE` SQL anterior.

## Protocolo de conciliación masiva

1. Autenticarse localmente contra la misma base usada por la UI.
2. Pedir ambos JSON con idénticos `empresa`, `sucursal`, `fdel`, `fal`.
3. Agrupar Kardex por producto/unidad normalizada.
4. Tomar solo la existencia más reciente por llave.
5. Comparar con `inventario_final` de Detalle, tolerancia `0.0001`.
6. Clasificar:
   - `COINCIDE`
   - `DIFERENCIA_REAL`
   - `SOLO_DETALLE_SIN_MOVIMIENTO`
   - `SOLO_KARDEX_SIN_REFERENCIA`
7. Trazar cada excepción a activo/tipo, unidad, documento y tabla origen antes
   de corregir.

### Resultado integral verificado

Empresa `30`, sucursal `113`, `2026-05-31..2026-07-29`:

- Kardex: `5,672` filas, `95` llaves.
- Detalle: `143` llaves activas.
- Intersección: `93`.
- Diferencias numéricas reales: `0`.
- Total Detalle: `5,386,750.0800`.
- Card Kardex: `5,386,750.0800`.
- Diferencia global: `0.0000`.
- `50` llaves solo en Detalle no tuvieron movimientos.
- `2` llaves solo en Kardex fueron las excepciones 67/D12 descritas.

Validaciones focales:

- `BARRIL DUNKEL`, `2026-05-31..2026-07-22`: `457,350.0000`, incluso
  filtrando siete ajustes positivos.
- `F14 / AGUA TONICA`, `2026-05-31..2026-07-29`: 7 movimientos, entradas 0,
  salidas `8,310`, cierre `-1,400`, igual a Detalle.

## Checklist de regresión

- Fijar repo, rama, base, empresa y sucursal.
- Usar exactamente las mismas fechas.
- Verificar HTTP, JSON y ausencia de HTML/warnings.
- Confirmar exclusión de servicios.
- Probar búsqueda código + nombre.
- Probar filtros DevExtreme.
- Sumar entradas/salidas, pero un solo cierre por llave.
- Separar inactivos y unidades anómalas.
- Incluir un producto sin movimientos y otro con varios tipos.
- Ejecutar lint PHP, check JavaScript y `git diff --check`.
- No versionar credenciales ni artefactos de conciliación.

## Commits relevantes

- `7fcf1f85`: apertura de inventario y Kardex.
- `2a6939ed`: último/inventario inicial.
- `acb1fec8`: mejoras Kardex.
- `74485396`: método de costeo en Detalle.
- `24b68e01`: existencia final bajo filtros.
- `3c4cd01a`: CPP periódico limitado.
- `6646e960`: homologación y exclusión de servicios.
- `f99dafbe`: búsquedas compuestas.
