# Script to setup Dask Worker autostart on Windows
# Run this script after cloning the repository on a new machine

$PROJECT_DIR = $PSScriptRoot
$STARTUP_DIR = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$VBS_PATH = "$STARTUP_DIR\DaskWorker.vbs"

# Create VBS script for silent startup
$vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File $PROJECT_DIR\start_worker.ps1", 0
Set WshShell = Nothing
"@

# Write VBS file
$vbsContent | Out-File -FilePath $VBS_PATH -Encoding ASCII -Force

Write-Host "✓ Autostart configured successfully!" -ForegroundColor Green
Write-Host "  VBS file created at: $VBS_PATH" -ForegroundColor Cyan
Write-Host ""
Write-Host "The Dask Worker will start automatically on next Windows login." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Red
Write-Host "  1. Make sure to configure .env file with your scheduler IP" -ForegroundColor Yellow
Write-Host "  2. Disable ProtonVPN or configure split tunneling for Tailscale (100.0.0.0/8)" -ForegroundColor Yellow
Write-Host "  3. Make sure Tailscale is installed and connected" -ForegroundColor Yellow
