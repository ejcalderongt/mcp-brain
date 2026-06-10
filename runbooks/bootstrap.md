# Bootstrap MCP Brain

## 1) Clonar brain
```powershell
git clone https://github.com/ejcalderongt/mcp-brain.git C:\Users\$env:USERNAME\source\repos\MCP\mcp-brain
```

## 2) Clonar código fuente
```powershell
git clone https://ejcalderongt.visualstudio.com/mposbi/_git/mposbi C:\Users\$env:USERNAME\source\repos\MCP\mposbi
cd C:\Users\$env:USERNAME\source\repos\MCP\mposbi
git remote add neworigin https://ejcalderon0892@dev.azure.com/ejcalderon0892/MCP/_git/MCP
```

## 3) Restaurar utilidades
```powershell
Copy-Item C:\Users\$env:USERNAME\source\repos\MCP\mcp-brain\scripts\* C:\Users\$env:USERNAME\source\repos\MCP\mposbi\scripts -Recurse -Force
```

## 4) Ejecutar validación kardex
```powershell
cd C:\Users\$env:USERNAME\source\repos\MCP\mposbi
powershell -ExecutionPolicy Bypass -File .\scripts\Validate-MovimientosKardex.ps1
```
