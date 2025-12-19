# Dask Worker

Worker de Dask para procesamiento distribuido de documentos con Docling sobre red Tailscale.

## Requisitos

- Windows 10/11
- [UV](https://github.com/astral-sh/uv) instalado
- [Tailscale](https://tailscale.com/) instalado y configurado
- Acceso al scheduler de Dask en la red Tailscale

## Instalación

1. **Clonar el repositorio:**
   ```powershell
   git clone <tu-repo-url>
   cd DaskWorker
   ```

2. **Instalar dependencias con UV:**
   ```powershell
   uv sync
   ```
   
   Esto creará automáticamente el entorno virtual en `.venv` e instalará todas las dependencias incluyendo:
   - Dask y Distributed
   - Docling con todas sus dependencias (PyTorch, transformers, etc.)
   - Todas las librerías necesarias con versiones fijas

3. **Configurar variables de entorno:**
   
   Copia el archivo de ejemplo:
   ```powershell
   Copy-Item .env.example .env
   ```
   
   Edita `.env` con la IP de tu scheduler de Dask:
   ```
   SCHEDULER_IP=<IP-del-scheduler-en-tailscale>
   SCHEDULER_PORT=8786
   WORKER_NAME=worker-1
   ```

4. **Configurar inicio automático (opcional pero recomendado):**
   
   Ejecuta el script de configuración para que el worker se inicie automáticamente al arrancar Windows:
   ```powershell
   .\setup_autostart.ps1
   ```
   
   Esto creará un script VBS en la carpeta de inicio de Windows.

## Uso

### Scripts Disponibles

**`setup_autostart.ps1`** - Configuración inicial (ejecutar UNA VEZ):
- Crea un archivo VBS en la carpeta de inicio de Windows
- Configura el inicio automático del worker al arrancar el sistema
- Solo necesitas ejecutarlo una vez después de clonar el repositorio

**`start_worker.ps1`** - Inicio del worker:
- Inicia el worker de Dask y lo conecta al scheduler
- Se ejecuta automáticamente al iniciar sesión (si configuraste el autostart)
- También puedes ejecutarlo manualmente cuando lo necesites

**Relación entre los scripts:**
`setup_autostart.ps1` crea un VBS que ejecuta automáticamente `start_worker.ps1` cada vez que inicias sesión en Windows.

### Inicio Automático

El worker se iniciará automáticamente al arrancar Windows gracias al script VBS en la carpeta de inicio (`DaskWorker.vbs`).

**IMPORTANTE:** Asegúrate de que ProtonVPN u otras VPNs tradicionales estén desconectadas, ya que bloquean el tráfico de Tailscale.

### Iniciar el Worker Manualmente

```powershell
.\start_worker.ps1
```

El worker se conectará al scheduler y estará listo para procesar tareas.

### Verificar el Worker

Revisa el archivo de log para confirmar la conexión:
```powershell
Get-Content worker.log -Tail 20
```

Deberías ver mensajes como:
```
distributed.worker - INFO - Registered to: tcp://<SCHEDULER_IP>:8786
distributed.core - INFO - Starting established connection to tcp://<SCHEDULER_IP>:8786
```

### Detener el Worker

Presiona `Ctrl+C` en la terminal donde se está ejecutando el worker, o:
```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*distributed.cli.dask_worker*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

## Estructura del Proyecto

```
DaskWorker/
├── .venv/                 # Entorno virtual (generado automáticamente)
├── .env                   # Configuración local (no se sube a Git)
├── .env.example           # Plantilla de configuración
├── .gitignore             # Archivos ignorados por Git
├── pyproject.toml         # Dependencias del proyecto
├── start_worker.ps1       # Script para iniciar el worker
├── setup_autostart.ps1    # Script para configurar inicio automático
├── main.py                # Script principal (opcional)
├── README.md              # Este archivo
└── worker.log             # Log del worker (generado en runtime)
```

## Configuración Avanzada

### Variables de Entorno Disponibles

- `SCHEDULER_IP`: IP del scheduler en Tailscale (requerido)
- `SCHEDULER_PORT`: Puerto del scheduler (default: 8786)
- `WORKER_NAME`: Nombre identificador del worker (opcional)

### Múltiples Workers

Puedes ejecutar múltiples workers en la misma máquina asignando nombres diferentes:
```powershell
$env:WORKER_NAME = "worker-2"
.\start_worker.ps1
```

## Solución de Problemas

### El scheduler no ve el worker

1. **Desconecta ProtonVPN o cualquier otra VPN**: Las VPNs tradicionales bloquean el tráfico de Tailscale. Debes desconectar ProtonVPN antes de iniciar el worker, o configurar split tunneling para excluir el rango `100.0.0.0/8`.

2. Verifica conectividad a Tailscale:
   ```powershell
   Test-NetConnection -ComputerName <SCHEDULER_IP> -Port 8786
   ```

3. Revisa el log del worker:
   ```powershell
   Get-Content worker.log
   ```

4. Asegúrate de que todas las máquinas tengan las mismas versiones de dependencias

### Errores de versión

Si ves advertencias de versiones incompatibles, sincroniza las dependencias:
```powershell
uv sync
```

## Dependencias Principales

- **Dask/Distributed**: Framework de computación distribuida
- **Docling**: Procesamiento de documentos con IA
- **PyTorch**: Motor de deep learning
- **Transformers**: Modelos de NLP de Hugging Face

Ver [pyproject.toml](pyproject.toml) para la lista completa de dependencias con versiones fijas.
