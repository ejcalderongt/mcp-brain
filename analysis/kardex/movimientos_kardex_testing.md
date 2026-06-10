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

## Uso para diagnostico
1. Ejecutar script.
2. Revisar `summary.md` para detectar casos fallidos o lentos.
3. Abrir `<case>.json` y validar:
   - `debug.filtros`
   - `debug.resultado`
   - `debug.muestra_productos_q`
   - `debug.sql`
4. Corregir query/filtros y volver a ejecutar para comparar.
