# OpenClaw Bot Monitor - System Tray Utility
# Universal version - works for any OpenClaw user (local or remote)
# https://github.com/lougerone/openclaw-monitor

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

# Config file path
$script:ConfigPath = "$env:LOCALAPPDATA\OpenClawMonitor\config.json"

# Default configuration
$script:CheckInterval = 30000  # 30 seconds
$script:GatewayUrl = "http://127.0.0.1:18789"
$script:lastState = $null

# Load config from file
function Load-Config {
    if (Test-Path $script:ConfigPath) {
        try {
            $config = Get-Content $script:ConfigPath | ConvertFrom-Json
            if ($config.GatewayUrl) { $script:GatewayUrl = $config.GatewayUrl }
            if ($config.CheckInterval) { $script:CheckInterval = $config.CheckInterval }
        } catch {}
    }
}

# Save config to file
function Save-Config {
    $configDir = Split-Path $script:ConfigPath
    if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
    @{
        GatewayUrl = $script:GatewayUrl
        CheckInterval = $script:CheckInterval
    } | ConvertTo-Json | Set-Content $script:ConfigPath
}

# Load saved config
Load-Config

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

$menuServer = New-Object System.Windows.Forms.ToolStripMenuItem
$menuServer.Text = "Server: --"
$menuServer.Enabled = $false
$contextMenu.Items.Add($menuServer) | Out-Null

$contextMenu.Items.Add("-") | Out-Null

$menuDashboard = New-Object System.Windows.Forms.ToolStripMenuItem
$menuDashboard.Text = "Open Dashboard"
$menuDashboard.Add_Click({ Start-Process $script:GatewayUrl })
$contextMenu.Items.Add($menuDashboard) | Out-Null

$menuLogs = New-Object System.Windows.Forms.ToolStripMenuItem
$menuLogs.Text = "View Logs (Local WSL)"
$menuLogs.Add_Click({
    Start-Process "wsl" -ArgumentList "-e", "bash", "-c", "source ~/.nvm/nvm.sh 2>/dev/null; openclaw logs --follow || openclaw logs"
})
$contextMenu.Items.Add($menuLogs) | Out-Null

$menuRestart = New-Object System.Windows.Forms.ToolStripMenuItem
$menuRestart.Text = "Restart Gateway (Local)"
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
$menuSettings.Add_Click({ Show-SettingsDialog })
$contextMenu.Items.Add($menuSettings) | Out-Null

$contextMenu.Items.Add("-") | Out-Null

$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout.Text = "About"
$menuAbout.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "OpenClaw Monitor v1.0.6`n`nA system tray utility to monitor your OpenClaw bot.`nSupports local and remote servers.`n`nGreen = Online`nRed = Offline`nYellow = Checking`n`nServer: $($script:GatewayUrl)`n`nhttps://openclaw.ai",
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

# Settings Dialog
function Show-SettingsDialog {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "OpenClaw Monitor Settings"
    $form.Size = New-Object System.Drawing.Size(450, 280)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = [System.Drawing.Color]::White

    # Server URL
    $lblUrl = New-Object System.Windows.Forms.Label
    $lblUrl.Text = "Gateway URL:"
    $lblUrl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblUrl.Location = New-Object System.Drawing.Point(20, 20)
    $lblUrl.AutoSize = $true
    $form.Controls.Add($lblUrl)

    $txtUrl = New-Object System.Windows.Forms.TextBox
    $txtUrl.Text = $script:GatewayUrl
    $txtUrl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $txtUrl.Location = New-Object System.Drawing.Point(20, 45)
    $txtUrl.Size = New-Object System.Drawing.Size(390, 28)
    $form.Controls.Add($txtUrl)

    $lblUrlHint = New-Object System.Windows.Forms.Label
    $lblUrlHint.Text = "Examples: http://127.0.0.1:18789  or  http://myserver.com:18789"
    $lblUrlHint.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $lblUrlHint.ForeColor = [System.Drawing.Color]::Gray
    $lblUrlHint.Location = New-Object System.Drawing.Point(20, 75)
    $lblUrlHint.AutoSize = $true
    $form.Controls.Add($lblUrlHint)

    # Check interval
    $lblInterval = New-Object System.Windows.Forms.Label
    $lblInterval.Text = "Check interval (seconds):"
    $lblInterval.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblInterval.Location = New-Object System.Drawing.Point(20, 110)
    $lblInterval.AutoSize = $true
    $form.Controls.Add($lblInterval)

    $txtInterval = New-Object System.Windows.Forms.NumericUpDown
    $txtInterval.Value = [int]($script:CheckInterval / 1000)
    $txtInterval.Minimum = 5
    $txtInterval.Maximum = 3600
    $txtInterval.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $txtInterval.Location = New-Object System.Drawing.Point(20, 135)
    $txtInterval.Size = New-Object System.Drawing.Size(100, 28)
    $form.Controls.Add($txtInterval)

    # Test button
    $btnTest = New-Object System.Windows.Forms.Button
    $btnTest.Text = "Test Connection"
    $btnTest.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $btnTest.Location = New-Object System.Drawing.Point(20, 185)
    $btnTest.Size = New-Object System.Drawing.Size(120, 32)
    $btnTest.Add_Click({
        try {
            $response = Invoke-WebRequest -Uri "$($txtUrl.Text)/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            [System.Windows.Forms.MessageBox]::Show("Connection successful!", "Test", "OK", "Information")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Connection failed: $($_.Exception.Message)", "Test", "OK", "Error")
        }
    })
    $form.Controls.Add($btnTest)

    # Save button
    $btnSave = New-Object System.Windows.Forms.Button
    $btnSave.Text = "Save"
    $btnSave.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnSave.Location = New-Object System.Drawing.Point(230, 185)
    $btnSave.Size = New-Object System.Drawing.Size(85, 32)
    $btnSave.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $btnSave.ForeColor = [System.Drawing.Color]::White
    $btnSave.FlatStyle = "Flat"
    $btnSave.Add_Click({
        $script:GatewayUrl = $txtUrl.Text.TrimEnd('/')
        $script:CheckInterval = [int]$txtInterval.Value * 1000
        $timer.Interval = $script:CheckInterval
        Save-Config
        Update-ServerDisplay
        $form.Close()
        Check-BotStatus
    })
    $form.Controls.Add($btnSave)

    # Cancel button
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $btnCancel.Location = New-Object System.Drawing.Point(325, 185)
    $btnCancel.Size = New-Object System.Drawing.Size(85, 32)
    $btnCancel.Add_Click({ $form.Close() })
    $form.Controls.Add($btnCancel)

    [void]$form.ShowDialog()
}

# Update server display in menu
function Update-ServerDisplay {
    $uri = [System.Uri]$script:GatewayUrl
    if ($uri.Host -eq "127.0.0.1" -or $uri.Host -eq "localhost") {
        $menuServer.Text = "Server: Local (:$($uri.Port))"
    } else {
        $menuServer.Text = "Server: $($uri.Host):$($uri.Port)"
    }
}

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
        # HTTP health check (works for local and remote)
        $response = Invoke-WebRequest -Uri "$script:GatewayUrl/health" -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
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
        # Check if it's a local server - try WSL fallback
        $uri = [System.Uri]$script:GatewayUrl
        if ($uri.Host -eq "127.0.0.1" -or $uri.Host -eq "localhost") {
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
                    return
                }
                elseif ($resultString -match "ok") {
                    $notifyIcon.Icon = $iconOnline
                    $notifyIcon.Text = "OpenClaw: ONLINE"
                    $menuStatus.Text = "Status: ONLINE"
                    $menuBotName.Text = "Gateway: Running"
                    $script:lastState = $true
                    return
                }
            } catch {}
        }

        # Offline
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

# Double-click opens dashboard
$notifyIcon.Add_DoubleClick({ Start-Process $script:GatewayUrl })

# Timer for periodic checks
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $script:CheckInterval
$timer.Add_Tick({ Check-BotStatus })
$timer.Start()

# Initial setup
Update-ServerDisplay
Check-BotStatus

# Run
[System.Windows.Forms.Application]::Run()
