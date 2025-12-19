# Wrapper script for Task Scheduler - logs all output for debugging
$ErrorActionPreference = "Continue"
$PROJECT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Log that wrapper started
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$wrapperLog = "$PROJECT_DIR\wrapper.log"
Add-Content -Path $wrapperLog -Value "`n=== $timestamp - Wrapper started ==="

try {
    # Execute the main script and capture output
    $output = & "$PROJECT_DIR\start_worker.ps1" 2>&1 | Out-String
    Add-Content -Path $wrapperLog -Value "Output:`n$output"
    
    Add-Content -Path $wrapperLog -Value "=== $timestamp - Wrapper completed successfully ==="
    exit 0
}
catch {
    Add-Content -Path $wrapperLog -Value "Error: $($_.Exception.Message)"
    Add-Content -Path $wrapperLog -Value "StackTrace: $($_.ScriptStackTrace)"
    Add-Content -Path $wrapperLog -Value "=== $timestamp - Wrapper failed ==="
    exit 1
}
