# OpenClaw Monitor Uninstaller

Add-Type -AssemblyName System.Windows.Forms

$result = [System.Windows.Forms.MessageBox]::Show(
    "This will uninstall OpenClaw Monitor.`n`n- Remove from Windows startup`n- Remove desktop shortcut`n- Stop running instance`n`nContinue?",
    "Uninstall OpenClaw Monitor",
    "YesNo",
    "Question"
)

if ($result -ne "Yes") {
    exit
}

Write-Host "Uninstalling OpenClaw Monitor..." -ForegroundColor Yellow

# Stop running instance
Write-Host "Stopping running instances..." -ForegroundColor Cyan
Get-Process | Where-Object { $_.MainWindowTitle -like "*OpenClaw*" -or $_.ProcessName -like "*OpenClawMonitor*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Stop-Process -Name "OpenClawMonitor" -Force -ErrorAction SilentlyContinue

# Remove from startup
$startupFolder = [Environment]::GetFolderPath('Startup')
$startupShortcut = Join-Path $startupFolder "OpenClaw Monitor.lnk"
if (Test-Path $startupShortcut) {
    Remove-Item $startupShortcut -Force
    Write-Host "Removed from startup" -ForegroundColor Green
} else {
    Write-Host "Not in startup (skipped)" -ForegroundColor Gray
}

# Remove desktop shortcut
$desktop = [Environment]::GetFolderPath('Desktop')
$desktopShortcut = Join-Path $desktop "OpenClaw Monitor.lnk"
if (Test-Path $desktopShortcut) {
    Remove-Item $desktopShortcut -Force
    Write-Host "Removed desktop shortcut" -ForegroundColor Green
} else {
    Write-Host "No desktop shortcut (skipped)" -ForegroundColor Gray
}

# Ask about removing exe
$scriptPath = $PSScriptRoot
if ($scriptPath) {
    $exePath = Join-Path $scriptPath "OpenClawMonitor.exe"
    if (Test-Path $exePath) {
        $deleteExe = [System.Windows.Forms.MessageBox]::Show(
            "Delete OpenClawMonitor.exe as well?",
            "Delete Program",
            "YesNo",
            "Question"
        )
        if ($deleteExe -eq "Yes") {
            Remove-Item $exePath -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted OpenClawMonitor.exe" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "OpenClaw Monitor uninstalled successfully!" -ForegroundColor Green

[System.Windows.Forms.MessageBox]::Show(
    "OpenClaw Monitor has been uninstalled.",
    "Uninstall Complete",
    "OK",
    "Information"
)
