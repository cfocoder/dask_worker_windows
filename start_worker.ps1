# Script to start Dask worker and connect to the scheduler
$PROJECT_DIR = $PSScriptRoot
$VENV_PATH = "$PROJECT_DIR\.venv"

# Load environment variables from .env file if it exists
if (Test-Path "$PROJECT_DIR\.env") {
    Get-Content "$PROJECT_DIR\.env" | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
}

# Get scheduler configuration from environment variables or use defaults
$SCHEDULER_IP = if ($env:SCHEDULER_IP) { $env:SCHEDULER_IP } else { "100.105.68.15" }
$SCHEDULER_PORT = if ($env:SCHEDULER_PORT) { $env:SCHEDULER_PORT } else { "8786" }
$WORKER_NAME = if ($env:WORKER_NAME) { $env:WORKER_NAME } else { "" }

# Change to project directory
Set-Location -Path $PROJECT_DIR

# Log startup
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path "$PROJECT_DIR\startup.log" -Value "$timestamp - Starting Dask Worker script"

# Build worker command
$workerCommand = "& `"$VENV_PATH\Scripts\python.exe`" -m distributed.cli.dask_worker `"tcp://$($SCHEDULER_IP):$($SCHEDULER_PORT)`" --no-nanny"

# Add worker name if specified
if ($WORKER_NAME) {
    $workerCommand += " --name `"$WORKER_NAME`""
}

# Add log redirection
$workerCommand += " >> `"$PROJECT_DIR\worker.log`" 2>&1"

Write-Host "Starting Dask Worker..."
Write-Host "Scheduler: tcp://$($SCHEDULER_IP):$($SCHEDULER_PORT)"
if ($WORKER_NAME) {
    Write-Host "Worker Name: $WORKER_NAME"
}
Write-Host "Log file: $PROJECT_DIR\worker.log"
Write-Host ""

# Build arguments list
$arguments = @("-m", "distributed.cli.dask_worker", "tcp://$($SCHEDULER_IP):$($SCHEDULER_PORT)", "--no-nanny")
if ($WORKER_NAME) {
    $arguments += @("--name", $WORKER_NAME)
}

# Start the dask worker in background using Start-Process
$processParams = @{
    FilePath = "$VENV_PATH\Scripts\python.exe"
    ArgumentList = $arguments
    RedirectStandardOutput = "$PROJECT_DIR\worker.log"
    RedirectStandardError = "$PROJECT_DIR\worker_error.log"
    NoNewWindow = $true
}

# Don't use WindowStyle when running from Task Scheduler (no interactive session)
if ([Environment]::UserInteractive) {
    $processParams['WindowStyle'] = 'Hidden'
}

$process = Start-Process @processParams -PassThru
Write-Host "Worker started with Process ID: $($process.Id)"
Write-Host ""
Write-Host "To check worker status: .\check_worker.ps1"
Write-Host "To view logs: Get-Content worker_error.log -Tail 20"

# Log the process ID
Add-Content -Path "$PROJECT_DIR\startup.log" -Value "$timestamp - Worker process started with PID: $($process.Id)"
