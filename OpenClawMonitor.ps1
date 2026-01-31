# OpenClaw Bot Monitor - System Tray Utility
# Universal version - works for any OpenClaw user
# https://github.com/user/openclaw-monitor

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration
$script:CheckInterval = 30000  # 30 seconds
$script:GatewayUrl = "http://127.0.0.1:18789"
$script:lastState = $null

# Create notification icon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true
$notifyIcon.Text = "OpenClaw Monitor"

# Create context menu
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

$menuStatus = New-Object System.Windows.Forms.ToolStripMenuItem
$menuStatus.Text = "Status: Checking..."
$menuStatus.Enabled = $false
$contextMenu.Items.Add($menuStatus) | Out-Null

$menuBotName = New-Object System.Windows.Forms.ToolStripMenuItem
$menuBotName.Text = "Bot: --"
$menuBotName.Enabled = $false
$contextMenu.Items.Add($menuBotName) | Out-Null

$contextMenu.Items.Add("-") | Out-Null

$menuDashboard = New-Object System.Windows.Forms.ToolStripMenuItem
$menuDashboard.Text = "Open Dashboard"
$menuDashboard.Add_Click({ Start-Process $script:GatewayUrl })
$contextMenu.Items.Add($menuDashboard) | Out-Null

$menuLogs = New-Object System.Windows.Forms.ToolStripMenuItem
$menuLogs.Text = "View Logs (WSL)"
$menuLogs.Add_Click({
    Start-Process "wsl" -ArgumentList "-e", "bash", "-c", "source ~/.nvm/nvm.sh 2>/dev/null; openclaw logs --follow || openclaw logs"
})
$contextMenu.Items.Add($menuLogs) | Out-Null

$menuRestart = New-Object System.Windows.Forms.ToolStripMenuItem
$menuRestart.Text = "Restart Gateway"
$menuRestart.Add_Click({
    $menuStatus.Text = "Status: Restarting..."
    Start-Process "wsl" -ArgumentList "-e", "bash", "-c", "source ~/.nvm/nvm.sh 2>/dev/null; openclaw gateway restart" -NoNewWindow -Wait
    Check-BotStatus
})
$contextMenu.Items.Add($menuRestart) | Out-Null

$contextMenu.Items.Add("-") | Out-Null

$menuCheckNow = New-Object System.Windows.Forms.ToolStripMenuItem
$menuCheckNow.Text = "Check Now"
$menuCheckNow.Add_Click({ Check-BotStatus })
$contextMenu.Items.Add($menuCheckNow) | Out-Null

$menuSettings = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSettings.Text = "Settings..."
$menuSettings.Add_Click({
    $interval = [Microsoft.VisualBasic.Interaction]::InputBox("Check interval in seconds:", "OpenClaw Monitor Settings", ($script:CheckInterval / 1000))
    if ($interval -and [int]::TryParse($interval, [ref]$null)) {
        $script:CheckInterval = [int]$interval * 1000
        $timer.Interval = $script:CheckInterval
        [System.Windows.Forms.MessageBox]::Show("Check interval set to $interval seconds", "OpenClaw Monitor", "OK", "Information")
    }
})
Add-Type -AssemblyName Microsoft.VisualBasic
$contextMenu.Items.Add($menuSettings) | Out-Null

$contextMenu.Items.Add("-") | Out-Null

$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout.Text = "About"
$menuAbout.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "OpenClaw Monitor v1.0.0`n`nA simple system tray utility to monitor your OpenClaw bot status.`n`nGreen = Online`nRed = Offline`nYellow = Checking`n`nhttps://openclaw.ai",
        "About OpenClaw Monitor",
        "OK",
        "Information"
    )
})
$contextMenu.Items.Add($menuAbout) | Out-Null

$menuExit = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit.Text = "Exit"
$menuExit.Add_Click({
    $notifyIcon.Visible = $false
    $timer.Stop()
    [System.Windows.Forms.Application]::Exit()
})
$contextMenu.Items.Add($menuExit) | Out-Null

$notifyIcon.ContextMenuStrip = $contextMenu

# Create icons
function Create-CircleIcon($color) {
    $bitmap = New-Object System.Drawing.Bitmap(16, 16)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = "AntiAlias"
    $brush = New-Object System.Drawing.SolidBrush($color)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 0, 0, 0), 1)
    $graphics.FillEllipse($brush, 1, 1, 13, 13)
    $graphics.DrawEllipse($pen, 1, 1, 13, 13)
    $brush.Dispose()
    $pen.Dispose()
    $graphics.Dispose()
    return [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
}

$iconOnline = Create-CircleIcon([System.Drawing.Color]::LimeGreen)
$iconOffline = Create-CircleIcon([System.Drawing.Color]::Red)
$iconChecking = Create-CircleIcon([System.Drawing.Color]::Gold)

$notifyIcon.Icon = $iconChecking

function Check-BotStatus {
    try {
        # Try HTTP health check first (works without WSL)
        $response = Invoke-WebRequest -Uri "$script:GatewayUrl/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        $health = $response.Content | ConvertFrom-Json

        $notifyIcon.Icon = $iconOnline
        $notifyIcon.Text = "OpenClaw: ONLINE"
        $menuStatus.Text = "Status: ONLINE"

        if ($health.telegram) {
            $menuBotName.Text = "Bot: @$($health.telegram.username)"
        } elseif ($health.channels) {
            $menuBotName.Text = "Channels: $($health.channels.Count) active"
        } else {
            $menuBotName.Text = "Gateway: Running"
        }

        if ($script:lastState -eq $false) {
            $notifyIcon.ShowBalloonTip(3000, "OpenClaw", "Bot is back online!", [System.Windows.Forms.ToolTipIcon]::Info)
        }
        $script:lastState = $true
    }
    catch {
        # Fallback: try WSL health check
        try {
            $result = & wsl -e bash -c "source ~/.nvm/nvm.sh 2>/dev/null; openclaw health 2>&1" 2>&1
            $resultString = $result -join "`n"

            if ($resultString -match "Telegram: ok \((@\w+)\)") {
                $botName = $matches[1]
                $notifyIcon.Icon = $iconOnline
                $notifyIcon.Text = "OpenClaw: ONLINE"
                $menuStatus.Text = "Status: ONLINE"
                $menuBotName.Text = "Bot: $botName"

                if ($script:lastState -eq $false) {
                    $notifyIcon.ShowBalloonTip(3000, "OpenClaw", "Bot is back online!", [System.Windows.Forms.ToolTipIcon]::Info)
                }
                $script:lastState = $true
            }
            elseif ($resultString -match "ok") {
                $notifyIcon.Icon = $iconOnline
                $notifyIcon.Text = "OpenClaw: ONLINE"
                $menuStatus.Text = "Status: ONLINE"
                $menuBotName.Text = "Gateway: Running"
                $script:lastState = $true
            }
            else {
                throw "Not healthy"
            }
        }
        catch {
            $notifyIcon.Icon = $iconOffline
            $notifyIcon.Text = "OpenClaw: OFFLINE"
            $menuStatus.Text = "Status: OFFLINE"
            $menuBotName.Text = "Bot: --"

            if ($script:lastState -eq $true) {
                $notifyIcon.ShowBalloonTip(5000, "OpenClaw", "Bot went offline!", [System.Windows.Forms.ToolTipIcon]::Warning)
            }
            $script:lastState = $false
        }
    }
}

# Double-click opens dashboard
$notifyIcon.Add_DoubleClick({ Start-Process $script:GatewayUrl })

# Timer for periodic checks
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $script:CheckInterval
$timer.Add_Tick({ Check-BotStatus })
$timer.Start()

# Initial check
Check-BotStatus

# Run
[System.Windows.Forms.Application]::Run()
