# OpenClaw Monitor Uninstaller
# Simple, one-click uninstall

Add-Type -AssemblyName System.Windows.Forms

$result = [System.Windows.Forms.MessageBox]::Show(
    "Uninstall OpenClaw Monitor?",
    "Uninstall",
    "YesNo",
    "Question"
)

if ($result -ne "Yes") { exit }

# Stop ONLY the OpenClawMonitor process (not Chrome or anything else)
Stop-Process -Name "OpenClawMonitor" -Force -ErrorAction SilentlyContinue

# Remove shortcuts silently
$startup = [Environment]::GetFolderPath('Startup')
$desktop = [Environment]::GetFolderPath('Desktop')
Remove-Item "$startup\OpenClaw Monitor.lnk" -Force -ErrorAction SilentlyContinue
Remove-Item "$desktop\OpenClaw Monitor.lnk" -Force -ErrorAction SilentlyContinue

[System.Windows.Forms.MessageBox]::Show(
    "Uninstalled! You can delete the EXE files manually.",
    "Done",
    "OK",
    "Information"
)
