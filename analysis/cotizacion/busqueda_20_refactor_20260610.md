# Cotizaciones - Busqueda 2.0 (Refactor UX + Rendimiento)

Fecha: 2026-06-10  
Autor tag tecnico: EJC20260608_BUSQUEDA2_COTIZACION

## Objetivo funcional
- Activar un modo opcional `Probar busqueda 2.0` en la pantalla de cotizaciones.
- En ese modo:
  - Ocultar combos tradicionales.
  - Mantener solo rango de fechas + barra avanzada.
  - Permitir busqueda estilo Jira/GitHub con `campo:valor` y texto libre.
  - Aplicar fallback inteligente de rango (-30 dias) cuando no hay resultados.

## Archivos de codigo tocados
- application/views/cotizacion/menu.php
- assets/js/cotizacion/base.js
- application/models/cotizacion/D_cotizacion_enc_model.php

## Como usar la barra avanzada
Ejemplos:
- `cliente:pilsener`
- `nit:12345 estado:nuevo`
- `doc:ov vendedor:juan`
- `producto:barril sucursal:zona10`
- `ov:00000123`

Campos soportados:
- `cliente`, `razon`, `nit`, `asunto`, `ov`, `correlativo`, `pais`, `vendedor`, `producto`
- Filtros de control desde barra: `estado`, `doc|tipo`, `sucursal|suc`, `vendedor|ven`

## Trazabilidad tecnica (simple)
1. UI agrega switch `Probar busqueda 2.0`.
2. Frontend parsea barra en:
   - filtros estructurados (estado/doc/sucursal/vendedor)
   - termino libre para busqueda full-text-like.
3. Backend interpreta texto:
   - LIKE en cliente, razon social, nit, asunto, vendedor, correlativo y OV.
   - EXISTS en detalle de cotizacion + producto para buscar por nombre/codigo de producto.
4. Si no hay datos con rango actual y hay criterio:
   - se amplia automaticamente 30 dias hacia atras una sola vez.
   - se deja traza en consola para debug.

## Impacto en rendimiento
- Se evita roundtrip manual de usuario para ampliar rango.
- Se mantiene compatibilidad con modo clasico (switch apagado).
- La condicion por producto se evalua solo cuando hay termino de busqueda.

## Riesgos y mitigacion
- Riesgo: terminos demasiado abiertos pueden aumentar tiempo de consulta.
- Mitigacion: mantener rango de fechas activo por defecto en modo 2.0 y fallback de una sola vez.

## Siguiente paso recomendado
- Crear SP de busqueda consolidada para cotizaciones con paging server-side y plan de indices.
