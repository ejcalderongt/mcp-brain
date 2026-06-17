# Cotizaciones - Canvas de busqueda tipo Jira (fase UX)

Fecha: 2026-06-10
Tag: EJC20260608_BUSQUEDA2_COTIZACION_CANVAS

## Que se agrego
- Switch `Probar busqueda 2.0`.
- Modo compacto: oculta combos tradicionales y deja fecha + barra inteligente.
- Canvas de busqueda al enfocar la barra, con tres pestañas:
  - Sugerencias
  - Recientes
  - Preview
- Chips de filtros activos (objetos): cada token se ve como objeto y se puede quitar con click.

## Como leer los objetos en pantalla
- `cliente:pilsener` => filtro directo por cliente.
- `estado:nuevo` => aplica estado del documento.
- `doc:ov` => solo ordenes de venta.
- `texto:algo` => termino libre en varios campos.

## Comportamiento tipo Jira
1. Escribes criterio.
2. El parser separa tokens por `campo:valor`.
3. El canvas muestra:
   - sugerencias contextuales (catálogos)
   - busquedas recientes del usuario (localStorage)
   - preview de resultados (top 8)
4. Enter o boton buscar ejecuta busqueda completa paginada.

## Rendimiento y seguridad de cambio
- Mantiene compatibilidad con modo clasico (switch apagado).
- Preview usa limite pequeño (`8`) y debounce (~280ms).
- Fallback inteligente de 30 dias sigue activo cuando no hay resultados.

## Archivos fuente modificados en mposbi
- application/views/cotizacion/menu.php
- assets/js/cotizacion/base.js
- application/models/cotizacion/D_cotizacion_enc_model.php

## Evolucion recomendada (fase backend pro)
- Endpoint `buscar_v2` con AST de filtros.
- SP paginado y ordenado con plan de indices.
- Integrar DevExpress FilterBuilder para expresiones visuales complejas.

## Ajuste posterior (hotfix 500)
- Se corrigio la construccion SQL de busqueda avanzada para evitar errores con `convert(...)` + `or_like`.
- Se agrego umbral minimo para preview (evita consultas agresivas con texto muy corto).
- Resultado esperado: menos ruido de requests y sin 500 en `cotizacion/cotizacion/buscar` por sintaxis SQL.
