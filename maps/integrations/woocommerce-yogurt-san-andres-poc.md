# WooCommerce Yogurt San Andres - POC de lectura

## Estado

- Fecha de observacion: 2026-07-21
- Fuente: WooCommerce REST API v3 del sitio Yogurt San Andres
- Alcance ejecutado: solicitudes `GET` exclusivamente
- Persistencia MCP: ninguna
- Credenciales: omitidas; no deben almacenarse en Brain ni en Git

## Conectividad y autenticacion confirmadas

La autenticacion HTTP Basic sobre HTTPS con una clave WooCommerce de lectura devolvio
`200 application/json` para productos, clientes, pedidos, pedidos modificados y
variaciones. Las colecciones incluyeron `X-WP-Total`, `X-WP-TotalPages` y `Link`.

Una solicitud sin autenticacion devolvio `403 text/html`. El cliente MCP debe distinguir
entre rechazo perimetral/HTML, errores JSON de WooCommerce, errores de credencial,
limitacion de tasa y fallos de transporte.

## Inventario observado

- Productos: 18 (17 publicados y 1 privado).
- Tipos: 4 simples y 14 variables.
- Variaciones referenciadas: 43.
- Productos sin SKU: 18 de 18.
- Las 43 variaciones leidas tampoco tienen SKU.
- Todos los productos y variaciones leidos tienen precio.
- Ningun producto observado administra existencias desde WooCommerce.

## Clientes y pedidos observados

- El endpoint de clientes reporto 0 registros.
- El endpoint de pedidos reporto 27,136 registros.
- Pedidos modificados desde 2026-07-01T00:00:00Z: 1,002 al momento de la prueba.
- Muestra reciente analizada: 100 pedidos y 1,487 lineas.
- Moneda de la muestra: GTQ.
- Origenes: 85 `checkout` y 15 `woocommerce-pos`.
- Clientes: 85 pedidos con `customer_id` y 15 pedidos de invitado.
- Las 1,487 lineas carecen de SKU.
- Lineas con variacion: 1,443 de 1,487.
- Estados observados: `pedidoingresado`, `pos-open`, `on-hold`, `pending` y `cancelled`.
- En otra muestra incremental aparecieron tambien `completed`.

La discrepancia entre cero clientes retornados y pedidos con `customer_id` debe
investigarse. No se debe asumir que `/customers` es la fuente suficiente para resolver
clientes. La POC debe validar `customer_id`, datos de facturacion y reglas para invitados.

## Campos legibles de alto valor

Pedidos exponen encabezado, facturacion, envio, moneda, fechas locales/GMT, estado,
metodo de pago, descuentos, impuestos, transporte, cargos, reembolsos, metadatos y
lineas. Las lineas exponen `product_id`, `variation_id`, cantidad, precio, subtotal,
total, impuestos, atributos/metadatos y SKU (actualmente vacio).

Productos y variaciones exponen IDs, tipo, estado, precios, atributos, imagenes,
categorias, dimensiones, peso, estado de stock, metadatos y fechas de modificacion.

## Invariantes para la POC MCP

1. Solo `GET`; no ejecutar POST, PUT, PATCH o DELETE.
2. No registrar secretos, encabezados Authorization ni PII completa.
3. Paginar usando `Link` y validar `X-WP-TotalPages`.
4. Usar fechas ISO 8601 con zona y un watermark que avance solo al terminar la corrida.
5. No emparejar productos por nombre.
6. La identidad candidata es `product_id + variation_id`; para Fase II se requiere SKU
   estable o una tabla explicita de equivalencias contra el producto MCP.
7. Los estados de integracion deben ser configurables porque existen estados
   personalizados.
8. Un pedido es elegible solo si todas sus lineas se pueden resolver y sus totales se
   reconcilian; no permitir traslado parcial.

## Pendientes con el proveedor WooCommerce

- Confirmar y documentar el significado/transicion de `pedidoingresado` y `pos-open`.
- Definir el estado exacto que habilitara el traslado a MCP.
- Asignar SKU estable a productos y variaciones o aceptar un catalogo de equivalencias.
- Explicar por que `/customers` retorna cero pese a existir pedidos con `customer_id`.
- Confirmar si WooCommerce es o no la fuente de stock; `manage_stock` fue falso en el
  catalogo observado.
- Rotar la clave expuesta en la captura y entregar una nueva clave de solo lectura por
  un canal seguro.

## Implementacion POC en MCP

Tag trazable: `#EJC20260721_WC_YSA_POC`.

- Configuracion segura: `application/config/woocommerce_yogurt_san_andres.php`.
- Cliente GET aislado: `application/libraries/integraciones/WooCommerce_read_client.php`.
- Controlador: `application/controllers/servicios/integraciones/Woocommerce.php`.
- Vista: `application/views/servicios/integraciones/woocommerce/principal.php`.
- JavaScript: `assets/js/servicios/integraciones/woocommerce/principal.js`.
- Operacion: `docs/integraciones/woocommerce-yogurt-san-andres.md`.
- Contrato estatico: `scripts/tests/Test-WooCommerceReadClient.php`.

La ruta `/index.php/servicios/integraciones/woocommerce` ejecuta un diagnostico
autenticado desde una sesion MCP. La respuesta es deliberadamente resumida: estado
HTTP, duracion, paginacion y calidad basica. No devuelve secretos ni PII.

## Deteccion casi inmediata de pedidos

El diseno recomendado es webhook mas reconciliacion, no polling continuo:

1. WooCommerce emite `order.updated` cuando cambia el pedido.
2. Un endpoint MCP publico valida la firma HMAC antes de aceptar el evento.
3. El receptor persiste un inbox idempotente y responde `2xx` rapidamente.
4. Un worker vuelve a consultar el pedido por REST API y evalua el estado actual.
5. Solo un estado configurado como elegible entra a validacion/importacion atomica.
6. Un job cada 2-5 minutos consulta `modified_after` con solapamiento para recuperar
   eventos perdidos, duplicados o fuera de orden.

El webhook es una notificacion, no la fuente final del pedido. La lectura posterior por
API evita procesar un payload incompleto o un estado que ya volvio a cambiar.

Productos, variaciones, clientes y precios usan sincronizacion incremental por
`date_modified_gmt`; los webhooks pueden acelerar el cambio, pero una barrida periodica
es el control de convergencia. Para invitados, el cliente se deriva de `billing`.
