# Cotizaciones - Aplicacion real en Amazon QA

Fecha: 2026-06-10
Tag: EJC20260610_COTIZACION_BUSQUEDA2_DB_APLICADO_QA

Se aplico exitosamente el paquete DB de busqueda 2.0 en:
- Server: 52.41.114.122,1437
- DB: mpos_pollo_express_qa

Objetos confirmados:
- IX_d_cotizacion_enc_busqueda_v2
- IX_p_usuario_sucursal_usuario_activo_sucursal
- IX_d_cotizacion_det_cot_anulado_producto
- IX_p_producto_codigo_producto_codigo_nombre
- IX_p_cliente_codigo_nombre_razon_nit
- dbo.sp_cotizacion_buscar_v2

Ajustes de compatibilidad realizados en ejecucion:
- Cambio a columna producto `desclarga`.
- Eliminacion de funciones no soportadas (`TRY_CONVERT`, `STRING_SPLIT`).

Pendiente sugerido:
- Integrar uso de SP desde backend PHP bajo feature flag para comparar p95/p99.
