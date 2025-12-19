# Script to check if Dask Worker is running and display status

Write-Host "`n=== Dask Worker Status ===" -ForegroundColor Cyan
Write-Host ""

# Check if worker process is running
$workerProcess = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*distributed.cli.dask_worker*" }

if ($workerProcess) {
    Write-Host "✓ Worker is RUNNING" -ForegroundColor Green
    Write-Host ""
    $workerProcess | ForEach-Object {
        Write-Host "  Process ID: $($_.ProcessId)"
        Write-Host "  Started: $($_.CreationDate)"
        Write-Host "  Command: $($_.CommandLine)"
    }
} else {
    Write-Host "✗ Worker is NOT running" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Task Scheduler Status ===" -ForegroundColor Cyan
Write-Host ""

$taskInfo = Get-ScheduledTaskInfo -TaskName 'DaskWorkerAutostart' -ErrorAction SilentlyContinue
if ($taskInfo) {
    $task = Get-ScheduledTask -TaskName 'DaskWorkerAutostart'
    Write-Host "  Task State: $($task.State)"
    Write-Host "  Last Run: $($taskInfo.LastRunTime)"
    
    if ($taskInfo.LastTaskResult -eq 0) {
        Write-Host "  Last Result: Success (0)" -ForegroundColor Green
    } else {
        Write-Host "  Last Result: Failed ($($taskInfo.LastTaskResult))" -ForegroundColor Red
    }
    
    if ($taskInfo.NextRunTime) {
        Write-Host "  Next Run: $($taskInfo.NextRunTime)"
    } else {
        Write-Host "  Next Run: At next logon"
    }
} else {
    Write-Host "  Task not configured. Run .\setup_task_scheduler.ps1" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Network Connectivity ===" -ForegroundColor Cyan
Write-Host ""

# Check scheduler connectivity
$schedulerIP = $env:SCHEDULER_IP ?? "100.105.68.15"
$schedulerPort = $env:SCHEDULER_PORT ?? "8786"

$connection = Test-NetConnection -ComputerName $schedulerIP -Port $schedulerPort -WarningAction SilentlyContinue

if ($connection.TcpTestSucceeded) {
    Write-Host "✓ Scheduler is REACHABLE at tcp://$($schedulerIP):$($schedulerPort)" -ForegroundColor Green
} else {
    Write-Host "✗ Cannot reach scheduler at tcp://$($schedulerIP):$($schedulerPort)" -ForegroundColor Red
    Write-Host "  Make sure Tailscale is connected and ProtonVPN is disconnected" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Recent Logs ===" -ForegroundColor Cyan
Write-Host ""

# Show recent startup log
if (Test-Path "$PSScriptRoot\startup.log") {
    Write-Host "Startup Log (last 3 lines):"
    Get-Content "$PSScriptRoot\startup.log" -Tail 3 | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "  No startup.log found"
}

Write-Host ""

# Show recent worker errors
if (Test-Path "$PSScriptRoot\worker_error.log") {
    $errorLog = Get-Content "$PSScriptRoot\worker_error.log" -Tail 5
    if ($errorLog -match "Registered to:") {
        Write-Host "✓ Worker successfully registered to scheduler" -ForegroundColor Green
    }
} else {
    Write-Host "  No worker_error.log found"
}

Write-Host ""
