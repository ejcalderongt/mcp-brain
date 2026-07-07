# MCP Brain Repository

Repositorio central para brains, runbooks, scripts y análisis del proyecto MCP.

## Restauración rápida
```powershell
git clone https://github.com/ejcalderongt/mcp-brain.git C:\Users\%USERNAME%\source\repos\MCP\mcp-brain
cd C:\Users\%USERNAME%\source\repos\MCP\mcp-brain
```

## Estructura
- `brains/mcp-context/` contexto persistente del sistema MCP
- `brains/mcp-context/maps/project-navigation-playbook.md` ruta rápida para ubicar repo, módulo, tablas y validación
- `brains/mcp-context/maps/variant-aware-report-contract.md` contrato reusable para reportes con talla/color o variantes
- `analysis/kardex/` trazas y análisis del reporte kardex
- `scripts/` herramientas de validación/diagnóstico
- `runbooks/` guías operativas y recuperación

## Regla operativa
Todo artefacto generado por agentes (trazas, análisis, evidencia, scripts de diagnóstico, brains y yaml) se versiona aquí, no en el repo de código fuente.
