# OpenClaw Monitor Installer
# Professional installation wizard

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenClaw Monitor Setup"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Logo/Header panel
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(500, 80)
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Controls.Add($headerPanel)

# Logo (claw emoji as text)
$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Text = [char]::ConvertFromUtf32(0x1F99E)  # Lobster emoji
$logoLabel.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 36)
$logoLabel.ForeColor = [System.Drawing.Color]::White
$logoLabel.Location = New-Object System.Drawing.Point(20, 10)
$logoLabel.AutoSize = $true
$headerPanel.Controls.Add($logoLabel)

# Title
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "OpenClaw Monitor"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Location = New-Object System.Drawing.Point(90, 12)
$titleLabel.AutoSize = $true
$headerPanel.Controls.Add($titleLabel)

# Subtitle
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "System tray monitor for your OpenClaw bot"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$subtitleLabel.ForeColor = [System.Drawing.Color]::LightGray
$subtitleLabel.Location = New-Object System.Drawing.Point(92, 48)
$subtitleLabel.AutoSize = $true
$headerPanel.Controls.Add($subtitleLabel)

# Welcome text
$welcomeLabel = New-Object System.Windows.Forms.Label
$welcomeLabel.Text = "Welcome to the OpenClaw Monitor installer.`n`nThis will install:"
$welcomeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$welcomeLabel.Location = New-Object System.Drawing.Point(30, 100)
$welcomeLabel.Size = New-Object System.Drawing.Size(440, 50)
$form.Controls.Add($welcomeLabel)

# Features list
$featuresLabel = New-Object System.Windows.Forms.Label
$featuresLabel.Text = "  • OpenClaw Monitor - system tray status indicator`n  • Desktop shortcut`n  • Start with Windows (optional)"
$featuresLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$featuresLabel.ForeColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$featuresLabel.Location = New-Object System.Drawing.Point(30, 145)
$featuresLabel.Size = New-Object System.Drawing.Size(440, 50)
$form.Controls.Add($featuresLabel)

# Install location label
$locationLabel = New-Object System.Windows.Forms.Label
$locationLabel.Text = "Install location:"
$locationLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$locationLabel.Location = New-Object System.Drawing.Point(30, 210)
$locationLabel.AutoSize = $true
$form.Controls.Add($locationLabel)

# Install path textbox
$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.Text = "$env:LOCALAPPDATA\OpenClawMonitor"
$pathBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pathBox.Location = New-Object System.Drawing.Point(30, 235)
$pathBox.Size = New-Object System.Drawing.Size(340, 25)
$form.Controls.Add($pathBox)

# Browse button
$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "Browse..."
$browseBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$browseBtn.Location = New-Object System.Drawing.Point(380, 233)
$browseBtn.Size = New-Object System.Drawing.Size(80, 27)
$browseBtn.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select installation folder"
    $folderBrowser.SelectedPath = $pathBox.Text
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $pathBox.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseBtn)

# Startup checkbox
$startupCheck = New-Object System.Windows.Forms.CheckBox
$startupCheck.Text = "Start OpenClaw Monitor when Windows starts"
$startupCheck.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$startupCheck.Location = New-Object System.Drawing.Point(30, 275)
$startupCheck.Size = New-Object System.Drawing.Size(300, 25)
$startupCheck.Checked = $true
$form.Controls.Add($startupCheck)

# Launch checkbox
$launchCheck = New-Object System.Windows.Forms.CheckBox
$launchCheck.Text = "Launch OpenClaw Monitor after installation"
$launchCheck.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$launchCheck.Location = New-Object System.Drawing.Point(30, 300)
$launchCheck.Size = New-Object System.Drawing.Size(300, 25)
$launchCheck.Checked = $true
$form.Controls.Add($launchCheck)

# Install button
$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Text = "Install"
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$installBtn.Location = New-Object System.Drawing.Point(280, 330)
$installBtn.Size = New-Object System.Drawing.Size(90, 32)
$installBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$installBtn.ForeColor = [System.Drawing.Color]::White
$installBtn.FlatStyle = "Flat"
$installBtn.Add_Click({
    $installPath = $pathBox.Text

    try {
        # Create directory
        if (!(Test-Path $installPath)) {
            New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        }

        # Copy files
        $scriptDir = Split-Path -Parent $PSScriptRoot
        if (!$scriptDir) { $scriptDir = $PSScriptRoot }
        if (!$scriptDir) { $scriptDir = (Get-Location).Path }

        Copy-Item "$scriptDir\OpenClawMonitor.exe" -Destination $installPath -Force
        Copy-Item "$scriptDir\Uninstall.exe" -Destination $installPath -Force -ErrorAction SilentlyContinue

        # Create desktop shortcut
        $ws = New-Object -ComObject WScript.Shell
        $desktop = [Environment]::GetFolderPath('Desktop')
        $shortcut = $ws.CreateShortcut("$desktop\OpenClaw Monitor.lnk")
        $shortcut.TargetPath = "$installPath\OpenClawMonitor.exe"
        $shortcut.WorkingDirectory = $installPath
        $shortcut.Description = "OpenClaw Bot Status Monitor"
        $shortcut.Save()

        # Create startup shortcut if checked
        if ($startupCheck.Checked) {
            $startup = [Environment]::GetFolderPath('Startup')
            $startupShortcut = $ws.CreateShortcut("$startup\OpenClaw Monitor.lnk")
            $startupShortcut.TargetPath = "$installPath\OpenClawMonitor.exe"
            $startupShortcut.WorkingDirectory = $installPath
            $startupShortcut.Save()
        }

        # Create uninstaller registry entry
        $uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenClawMonitor"
        New-Item -Path $uninstallKey -Force | Out-Null
        Set-ItemProperty -Path $uninstallKey -Name "DisplayName" -Value "OpenClaw Monitor"
        Set-ItemProperty -Path $uninstallKey -Name "UninstallString" -Value "$installPath\Uninstall.exe"
        Set-ItemProperty -Path $uninstallKey -Name "InstallLocation" -Value $installPath
        Set-ItemProperty -Path $uninstallKey -Name "Publisher" -Value "OpenClaw"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayVersion" -Value "1.0.2"
        Set-ItemProperty -Path $uninstallKey -Name "NoModify" -Value 1
        Set-ItemProperty -Path $uninstallKey -Name "NoRepair" -Value 1

        $form.Hide()

        [System.Windows.Forms.MessageBox]::Show(
            "OpenClaw Monitor installed successfully!`n`nLocation: $installPath",
            "Installation Complete",
            "OK",
            "Information"
        )

        # Launch if checked
        if ($launchCheck.Checked) {
            Start-Process "$installPath\OpenClawMonitor.exe"
        }

        $form.Close()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Installation failed: $($_.Exception.Message)",
            "Error",
            "OK",
            "Error"
        )
    }
})
$form.Controls.Add($installBtn)

# Cancel button
$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Cancel"
$cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$cancelBtn.Location = New-Object System.Drawing.Point(380, 330)
$cancelBtn.Size = New-Object System.Drawing.Size(80, 32)
$cancelBtn.Add_Click({ $form.Close() })
$form.Controls.Add($cancelBtn)

# Show form
[void]$form.ShowDialog()
