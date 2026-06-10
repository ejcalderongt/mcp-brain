# WS Method Inventory (MPOS)

## Tags
- `MPOS_WS`
- `MPOS_SYNC`
- `MPOS_CONFIG_SYNC`

## Transport Families
- SOAP (ksoap2 + `tempuri.org`):
  - base namespace: `mpos/app/src/main/java/com/dtsgt/webservice/wsBase.java:16`
  - dynamic SOAP builder: `mpos/app/src/main/java/com/dtsgt/classes/WebService.java:71`
- HTTP JSON commit:
  - `mpos/app/src/main/java/com/dtsgt/webapi/HttpCommit.java:40`

## Core Write Methods
- `Commit` (`SQL` payload):
  - `mpos/app/src/main/java/com/dtsgt/webservice/wsCommit.java:29`
  - used heavily by `WSEnv` callbacks: `mpos/app/src/main/java/com/dtsgt/mpos/WSEnv.java:229`

## Core Read Methods (Catalog/Config Pull)
Observed in `WSRec` callback dispatch:
- `GetP_EMPRESA`, `GetP_ARCHIVOCONF`, `GetP_COREL`, `GetP_IMPUESTO`, `GetP_LINEA`, `GetP_PRODUCTO`, `GetP_RUTA`, `GetP_SUCURSAL`
- `GetP_PARAMEXT`, `GetP_PARAMEXT_RUTA`, `GetP_REGLA_COSTO`
- `GetP_ALMACEN`, `GetP_MOTIVO_AJUSTE`, `GetP_PRODUCTO_TIPO`, `GetP_UNIDAD`, `GetP_UNIDAD_CONV`
- `GetP_MODIFICADOR`, `GetP_MODIFICADOR_GRUPO`, `GetP_PRODCLASIFMODIF`
- `GetP_BARRIL_TIPO`, `GetP_BARRIL_BARRA`, `GetP_CORTESIA`
- `GetP_VENDEDOR_ROL`, `GetP_VENDEDOR_SUCURSAL`, `GetP_TIPO_NEGOCIO`
- `GetP_IMPRESORA*`, `GetP_RES_*`, `GetP_GIRO_NEGOCIO`, `GetVENDEDORES`

Evidence block:
- `mpos/app/src/main/java/com/dtsgt/mpos/WSRec.java:250`
- `mpos/app/src/main/java/com/dtsgt/mpos/WSRec.java:339`
- `mpos/app/src/main/java/com/dtsgt/mpos/WSRec.java:416`
- `mpos/app/src/main/java/com/dtsgt/mpos/WSRec.java:420`

## Specialized ws* Class Method Names
From `com/dtsgt/webservice/ws*.java`:
- `wsCommit`: `Commit`
- `wsOpenDT`, `wsInvActual`, `wsInventCompartido`, `wsInventRecibir`: `getDT`
- `wsPedidosNuevos`, `wsPedNuevos`: `Pedidos_Nuevos`
- `wsPedidosImport`: `Pedidos_Import`
- `wsPedidosRecibidos`: `Pedidos_Recepcion`
- `wsOrdenImport`: `Caja_Ordenes`
- `wsOrdenRecall`: `Caja_Ordenes_Envio`
- `wsOrdenesRecibidos`: `Ordenes_Recepcion`
- `wsPedidoDatos`: `Pedido_Datos`
- `wsPedidoDir`: `Pedido_Direccion`
- `wsPedidosEstado`: `Pedido_Estado`
- `wsPedidosBitacora`: `Pedido_Bitacora`
- `wsInventConfirm`, `wsInvActual`: `invProcesado`
- `wsOrdenEnvio`, `wsInventEnvio`: `Commit`
- `wsFacturasFEL`: `facturas_FEL_validacion`

## HTTP Endpoints Observed
- `POST {apiurl}/api/Orden/Commit` (JSON with SQL)
  - `mpos/app/src/main/java/com/dtsgt/mpos/FacturaRes.java:4536`
  - `mpos/app/src/main/java/com/dtsgt/classes/clsEnvioPendiente.java:46`
- Additional HTTP request path for note-environment corel generation:
  - `mpos/app/src/main/java/com/dtsgt/mpos/FacturaRes.java:4491`

## Notes
- The platform is currently dual-channel (SOAP + HTTP SQL commit style).
- SOAP remains the dominant transactional channel for core sales/inventory synchronization.
