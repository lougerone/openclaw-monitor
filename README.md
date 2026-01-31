# OpenClaw Monitor

A simple Windows system tray utility to monitor your [OpenClaw](https://openclaw.ai) bot status.

![Status Icons](https://img.shields.io/badge/status-monitoring-brightgreen)

## Features

- **Real-time status** - Green/Red/Yellow indicator in system tray
- **Desktop notifications** - Get notified when bot goes online/offline
- **Quick actions** - Open dashboard, view logs, restart gateway
- **Lightweight** - Minimal resource usage, checks every 30 seconds
- **Auto-start** - Optional Windows startup integration

## Status Icons

| Icon | Meaning |
|------|---------|
| 🟢 Green | Bot is ONLINE |
| 🔴 Red | Bot is OFFLINE |
| 🟡 Yellow | Checking... |

## Installation

### Option 1: Download EXE (Recommended)
1. Download `OpenClawMonitor.exe` from [Releases](../../releases)
2. Run it - the icon appears in your system tray
3. (Optional) Add to startup folder for auto-start

### Option 2: Run from source
```powershell
powershell -ExecutionPolicy Bypass -File OpenClawMonitor.ps1
```

## Usage

- **Double-click** tray icon → Opens dashboard
- **Right-click** tray icon → Context menu with options:
  - Status display
  - Open Dashboard
  - View Logs (WSL)
  - Restart Gateway
  - Check Now
  - Settings (change check interval)
  - About
  - Exit

## Add to Windows Startup

1. Press `Win + R`
2. Type `shell:startup` and press Enter
3. Copy `OpenClawMonitor.exe` to this folder

Or run this PowerShell command:
```powershell
Copy-Item "OpenClawMonitor.exe" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\"
```

## Requirements

- Windows 10/11
- OpenClaw installed and running (via WSL or native)
- Gateway running on `localhost:18789` (default)

## Configuration

The monitor checks `http://127.0.0.1:18789/health` by default.

To change the check interval:
1. Right-click the tray icon
2. Click "Settings..."
3. Enter new interval in seconds

## Building from Source

Requires [PS2EXE](https://github.com/MScholtes/PS2EXE):

```powershell
Install-Module -Name ps2exe -Scope CurrentUser
Invoke-PS2EXE -InputFile OpenClawMonitor.ps1 -OutputFile OpenClawMonitor.exe -NoConsole
```

## License

MIT License - Feel free to modify and share!

## Links

- [OpenClaw](https://openclaw.ai)
- [OpenClaw Docs](https://docs.openclaw.ai)
- [Report Issues](../../issues)
