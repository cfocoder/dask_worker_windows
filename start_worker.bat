@echo off
setlocal EnableDelayedExpansion

REM Batch script to start Dask Worker - more reliable with Task Scheduler
cd /d %~dp0

REM Load environment variables from .env file
set SCHEDULER_IP=100.105.68.15
set SCHEDULER_PORT=8786
set WORKER_NAME=

if exist .env (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        set line=%%a
        if not "!line:~0,1!"=="#" (
            if "%%a"=="SCHEDULER_IP" set SCHEDULER_IP=%%b
            if "%%a"=="SCHEDULER_PORT" set SCHEDULER_PORT=%%b
            if "%%a"=="WORKER_NAME" set WORKER_NAME=%%b
        )
    )
)

REM Wait for Tailscale to be connected before starting worker
echo %date% %time% - Waiting for Tailscale connection... >> startup.log

:CHECK_TAILSCALE
tailscale status | findstr /C:"100.65.52.49" >nul 2>&1
if errorlevel 1 (
    echo %date% %time% - Tailscale not ready, waiting 5 seconds... >> startup.log
    timeout /t 5 /nobreak >nul
    goto CHECK_TAILSCALE
)

echo %date% %time% - Tailscale connected, starting Dask Worker >> startup.log

REM Start the worker using the venv python
if "%WORKER_NAME%"=="" (
    start "DaskWorker" /B .venv\Scripts\python.exe -m distributed.cli.dask_worker tcp://%SCHEDULER_IP%:%SCHEDULER_PORT% --no-nanny 1>> worker.log 2>> worker_error.log
) else (
    start "DaskWorker" /B .venv\Scripts\python.exe -m distributed.cli.dask_worker tcp://%SCHEDULER_IP%:%SCHEDULER_PORT% --no-nanny --name %WORKER_NAME% 1>> worker.log 2>> worker_error.log
)

echo %date% %time% - Worker started >> startup.log
