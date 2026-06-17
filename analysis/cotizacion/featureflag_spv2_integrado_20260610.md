# Cotizaciones - Integracion Feature Flag SP v2

Fecha: 2026-06-10
Tag: EJC20260610_COTIZACION_SPV2_FEATUREFLAG

Se integro feature flag backend/frontend para seleccionar motor de busqueda:
- `legacy` (query original)
- `sp_v2` (dbo.sp_cotizacion_buscar_v2)

Medicion comparativa:
- Con `spcmp=1` el endpoint ejecuta ambos motores y devuelve benchmark.
- La UI registra benchmark en consola para analisis rapido.

URL de prueba:
- `.../cotizacion/cotizacion?spv2=1&spcmp=1`
