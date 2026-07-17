# Automatizacion de validacion - Movimientos Kardex

## Objetivo
Estandarizar pruebas de diagnostico para el reporte `reportes/movimientos_kardex` con evidencia reproducible:
- estado HTTP
- tiempos
- cantidad de registros
- fallback inteligente aplicado
- payload de debug (filtros, SQL y muestra de productos)

## Script
- [Validate-MovimientosKardex.ps1](C:/Users/yejc2/source/repos/MCP/mposbi/scripts/Validate-MovimientosKardex.ps1)
- [Validate-DetalleExistenciasVsKardex.ps1](C:/Users/yejc2/source/repos/MCP/mposbi/scripts/Validate-DetalleExistenciasVsKardex.ps1)

## Ejecucion rapida
```powershell
cd C:\Users\yejc2\source\repos\MCP\mposbi
powershell -ExecutionPolicy Bypass -File .\scripts\Validate-MovimientosKardex.ps1
```

## Ejecucion con credenciales personalizadas
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Validate-MovimientosKardex.ps1 `
  -BaseUrl "http://127.0.0.1:8080" `
  -Username "admindts" `
  -Password "admincba123**"
```

## Salida esperada
Carpeta de artefactos:
- `artifacts/kardex-validation/<timestamp>/summary.csv`
- `artifacts/kardex-validation/<timestamp>/summary.json`
- `artifacts/kardex-validation/<timestamp>/summary.md`
- `artifacts/kardex-validation/<timestamp>/<case>.json`

Cada `<case>.json` incluye:
- request params
- resultado de la consulta
- bloque `debug` con filtros y SQL final

## Casos incluidos
1. `smoke_no_query`
2. `query_pilsener_same_day`
3. `query_pilsener_10_days`
4. `query_field_token` (`producto:pilsener`)

## Casos recomendados para comparacion con detalle_existencias
1. `9253`
2. `9254`
3. `9311`
4. `9345`
5. `9391`

## Comando de ejecucion del comparador
```powershell
cd C:\Users\yejc2\source\repos\MCP\mposbi
powershell -ExecutionPolicy Bypass -File .\scripts\Validate-DetalleExistenciasVsKardex.ps1
```

## Lectura del resultado
- `summary.md` resume si cada codigo quedo `OK` o `MISMATCH`.
- Cada `case-<codigo>.json` conserva el detalle por variante.
- Si Kardex pierde la variante, el comparador lo marca como gap y ya no hay que inferirlo a mano.

## Uso para diagnostico
1. Ejecutar script.
2. Revisar `summary.md` para detectar casos fallidos o lentos.
3. Abrir `<case>.json` y validar:
   - `debug.filtros`
   - `debug.resultado`
   - `debug.muestra_productos_q`
   - `debug.sql`
4. Corregir query/filtros y volver a ejecutar para comparar.

## Ultima corrida conocida

Ejecucion de referencia: `20260717-115241`

- `Cases: 5 / Mismatches: 3`
- `9311` -> OK
- `9345` -> OK
- `9253`, `9254`, `9391` -> MISMATCH

Lectura de negocio:
- el validator ya permite separar “match real” de “gap por variante/corte”.
- `detalle_existencias` ya debe publicar `inventario_inicial` como `Ultimo inventario` para hacer explicito el corte de arranque.
- el gap que sigue abierto no es de render sino de reconciliacion fina en algunas variantes sin corte claro.
- si la siguiente mejora es Kardex, el siguiente paso es decidir si la fuente de venta debe seguir siendo unica por empresa o si hace falta un selector de ledger por origen.
