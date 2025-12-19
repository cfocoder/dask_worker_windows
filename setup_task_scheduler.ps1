# Script to setup Dask Worker autostart using Windows Task Scheduler
# This is more reliable than Startup folder VBS scripts

$PROJECT_DIR = $PSScriptRoot
$TASK_NAME = "DaskWorkerAutostart"

Write-Host "Setting up Task Scheduler for Dask Worker autostart..."

# Remove existing task if it exists
$existingTask = Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Removing existing task..."
    Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false
}

# Create a new task action - run batch script (more reliable than PowerShell for background processes)
$action = New-ScheduledTaskAction `
    -Execute "cmd.exe" `
    -Argument "/c `"$PROJECT_DIR\start_worker.bat`"" `
    -WorkingDirectory $PROJECT_DIR

# Create a trigger that runs at logon with a 30 second delay to ensure network is ready
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$trigger.Delay = "PT30S"  # 30 seconds delay

# Create task settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Create the principal (user context)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

# Register the scheduled task
Register-ScheduledTask `
    -TaskName $TASK_NAME `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Starts Dask Worker and connects to scheduler via Tailscale"

Write-Host ""
Write-Host "✓ Task Scheduler configured successfully!"
Write-Host ""
Write-Host "Task Name: $TASK_NAME"
Write-Host "Trigger: At user logon ($env:USERNAME)"
Write-Host "Action: Run $PROJECT_DIR\start_worker.ps1"
Write-Host ""
Write-Host "You can manage this task using:"
Write-Host "  - Task Scheduler GUI: taskschd.msc"
Write-Host "  - PowerShell: Get-ScheduledTask -TaskName '$TASK_NAME'"
Write-Host ""
Write-Host "To test the task now: Start-ScheduledTask -TaskName '$TASK_NAME'"
Write-Host "To disable autostart: Disable-ScheduledTask -TaskName '$TASK_NAME'"
Write-Host "To remove autostart: Unregister-ScheduledTask -TaskName '$TASK_NAME' -Confirm:`$false"
