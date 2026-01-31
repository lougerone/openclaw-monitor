# OpenClaw Monitor Installer - Multi-Step Wizard (Fixed)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:currentStep = 1
$script:installPath = "$env:LOCALAPPDATA\OpenClawMonitor"
$script:addToStartup = $true
$script:createDesktopShortcut = $true
$script:createStartMenuShortcut = $true
$script:launchAfter = $true

# Main form - larger size to prevent text cutoff
$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenClaw Monitor Setup"
$form.Size = New-Object System.Drawing.Size(600, 480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Header panel
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(600, 70)
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(255, 100, 50)
$form.Controls.Add($headerPanel)

$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Text = [char]::ConvertFromUtf32(0x1F99E)
$logoLabel.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 28)
$logoLabel.ForeColor = [System.Drawing.Color]::White
$logoLabel.Location = New-Object System.Drawing.Point(15, 8)
$logoLabel.AutoSize = $true
$headerPanel.Controls.Add($logoLabel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "OpenClaw Monitor Setup"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Location = New-Object System.Drawing.Point(70, 20)
$titleLabel.AutoSize = $true
$headerPanel.Controls.Add($titleLabel)

# Content panel - larger
$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Size = New-Object System.Drawing.Size(600, 320)
$contentPanel.Location = New-Object System.Drawing.Point(0, 70)
$contentPanel.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($contentPanel)

# Footer panel
$footerPanel = New-Object System.Windows.Forms.Panel
$footerPanel.Size = New-Object System.Drawing.Size(600, 60)
$footerPanel.Location = New-Object System.Drawing.Point(0, 390)
$footerPanel.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Controls.Add($footerPanel)

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$progressLabel.ForeColor = [System.Drawing.Color]::Gray
$progressLabel.Location = New-Object System.Drawing.Point(20, 20)
$progressLabel.AutoSize = $true
$footerPanel.Controls.Add($progressLabel)

$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Cancel"
$cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$cancelBtn.Size = New-Object System.Drawing.Size(85, 32)
$cancelBtn.Location = New-Object System.Drawing.Point(310, 14)
$cancelBtn.Add_Click({ $form.Close() })
$footerPanel.Controls.Add($cancelBtn)

$backBtn = New-Object System.Windows.Forms.Button
$backBtn.Text = "< Back"
$backBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$backBtn.Size = New-Object System.Drawing.Size(85, 32)
$backBtn.Location = New-Object System.Drawing.Point(405, 14)
$backBtn.Add_Click({ $script:currentStep--; Show-Step $script:currentStep })
$footerPanel.Controls.Add($backBtn)

$nextBtn = New-Object System.Windows.Forms.Button
$nextBtn.Text = "Next >"
$nextBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$nextBtn.Size = New-Object System.Drawing.Size(85, 32)
$nextBtn.Location = New-Object System.Drawing.Point(500, 14)
$nextBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$nextBtn.ForeColor = [System.Drawing.Color]::White
$nextBtn.FlatStyle = "Flat"
$footerPanel.Controls.Add($nextBtn)

function Show-Step($step) {
    $contentPanel.Controls.Clear()
    $script:currentStep = $step

    switch ($step) {
        1 { Show-WelcomeStep }
        2 { Show-LocationStep }
        3 { Show-OptionsStep }
        4 { Show-InstallStep }
    }
}

function Show-WelcomeStep {
    $progressLabel.Text = "Step 1 of 3"
    $backBtn.Visible = $false
    $cancelBtn.Visible = $true
    $nextBtn.Text = "Next >"
    $nextBtn.Visible = $true

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Welcome to OpenClaw Monitor"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "This wizard will install OpenClaw Monitor on your computer.`n`nOpenClaw Monitor is a system tray utility that shows whether`nyour OpenClaw bot is online or offline.`n`nFeatures:`n`n    *  Real-time status indicator (green/red)`n    *  Desktop notifications when status changes`n    *  Quick access to dashboard and logs`n    *  One-click gateway restart`n`nClick Next to continue."
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $desc.Location = New-Object System.Drawing.Point(30, 60)
    $desc.Size = New-Object System.Drawing.Size(540, 250)
    $contentPanel.Controls.Add($desc)
}

function Show-LocationStep {
    $progressLabel.Text = "Step 2 of 3"
    $backBtn.Visible = $true
    $backBtn.Enabled = $true
    $cancelBtn.Visible = $true
    $nextBtn.Text = "Next >"
    $nextBtn.Visible = $true

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Choose Install Location"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "Select the folder where OpenClaw Monitor will be installed:"
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $desc.Location = New-Object System.Drawing.Point(30, 60)
    $desc.Size = New-Object System.Drawing.Size(540, 25)
    $contentPanel.Controls.Add($desc)

    $script:pathBox = New-Object System.Windows.Forms.TextBox
    $script:pathBox.Text = $script:installPath
    $script:pathBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:pathBox.Location = New-Object System.Drawing.Point(30, 100)
    $script:pathBox.Size = New-Object System.Drawing.Size(430, 28)
    $contentPanel.Controls.Add($script:pathBox)

    $browseBtn = New-Object System.Windows.Forms.Button
    $browseBtn.Text = "Browse..."
    $browseBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $browseBtn.Location = New-Object System.Drawing.Point(470, 99)
    $browseBtn.Size = New-Object System.Drawing.Size(90, 28)
    $browseBtn.Add_Click({
        $fb = New-Object System.Windows.Forms.FolderBrowserDialog
        $fb.Description = "Select installation folder"
        if ($fb.ShowDialog() -eq "OK") { $script:pathBox.Text = $fb.SelectedPath }
    })
    $contentPanel.Controls.Add($browseBtn)

    $space = New-Object System.Windows.Forms.Label
    $space.Text = "Space required: ~1 MB"
    $space.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $space.ForeColor = [System.Drawing.Color]::Gray
    $space.Location = New-Object System.Drawing.Point(30, 145)
    $space.AutoSize = $true
    $contentPanel.Controls.Add($space)
}

function Show-OptionsStep {
    $script:installPath = $script:pathBox.Text

    $progressLabel.Text = "Step 3 of 3"
    $backBtn.Visible = $true
    $backBtn.Enabled = $true
    $cancelBtn.Visible = $true
    $nextBtn.Text = "Install"
    $nextBtn.Visible = $true

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Installation Options"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $script:desktopCheck = New-Object System.Windows.Forms.CheckBox
    $script:desktopCheck.Text = "Create desktop shortcut"
    $script:desktopCheck.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $script:desktopCheck.Location = New-Object System.Drawing.Point(30, 80)
    $script:desktopCheck.Size = New-Object System.Drawing.Size(500, 28)
    $script:desktopCheck.Checked = $script:createDesktopShortcut
    $contentPanel.Controls.Add($script:desktopCheck)

    $script:startMenuCheck = New-Object System.Windows.Forms.CheckBox
    $script:startMenuCheck.Text = "Create Start Menu shortcut"
    $script:startMenuCheck.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $script:startMenuCheck.Location = New-Object System.Drawing.Point(30, 120)
    $script:startMenuCheck.Size = New-Object System.Drawing.Size(500, 28)
    $script:startMenuCheck.Checked = $script:createStartMenuShortcut
    $contentPanel.Controls.Add($script:startMenuCheck)

    $script:startupCheck = New-Object System.Windows.Forms.CheckBox
    $script:startupCheck.Text = "Start with Windows"
    $script:startupCheck.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $script:startupCheck.Location = New-Object System.Drawing.Point(30, 160)
    $script:startupCheck.Size = New-Object System.Drawing.Size(500, 28)
    $script:startupCheck.Checked = $script:addToStartup
    $contentPanel.Controls.Add($script:startupCheck)

    $script:launchCheck = New-Object System.Windows.Forms.CheckBox
    $script:launchCheck.Text = "Launch OpenClaw Monitor after installation"
    $script:launchCheck.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $script:launchCheck.Location = New-Object System.Drawing.Point(30, 200)
    $script:launchCheck.Size = New-Object System.Drawing.Size(500, 28)
    $script:launchCheck.Checked = $script:launchAfter
    $contentPanel.Controls.Add($script:launchCheck)
}

function Show-InstallStep {
    # Save options
    $script:createDesktopShortcut = $script:desktopCheck.Checked
    $script:createStartMenuShortcut = $script:startMenuCheck.Checked
    $script:addToStartup = $script:startupCheck.Checked
    $script:launchAfter = $script:launchCheck.Checked

    # Hide all buttons during install
    $progressLabel.Text = "Installing..."
    $backBtn.Visible = $false
    $cancelBtn.Visible = $false
    $nextBtn.Visible = $false

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Installing..."
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $script:statusLabel = New-Object System.Windows.Forms.Label
    $script:statusLabel.Text = "Preparing installation..."
    $script:statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:statusLabel.Location = New-Object System.Drawing.Point(30, 70)
    $script:statusLabel.Size = New-Object System.Drawing.Size(540, 30)
    $contentPanel.Controls.Add($script:statusLabel)

    $script:progressBar = New-Object System.Windows.Forms.ProgressBar
    $script:progressBar.Location = New-Object System.Drawing.Point(30, 110)
    $script:progressBar.Size = New-Object System.Drawing.Size(540, 28)
    $script:progressBar.Style = "Continuous"
    $contentPanel.Controls.Add($script:progressBar)

    $form.Refresh()

    try {
        # Create directory
        $script:statusLabel.Text = "Creating installation directory..."
        $script:progressBar.Value = 15
        $form.Refresh()
        if (!(Test-Path $script:installPath)) {
            New-Item -ItemType Directory -Path $script:installPath -Force | Out-Null
        }
        Start-Sleep -Milliseconds 300

        # Copy files
        $script:statusLabel.Text = "Copying files..."
        $script:progressBar.Value = 35
        $form.Refresh()
        $scriptDir = $PSScriptRoot
        if (!$scriptDir) { $scriptDir = (Get-Location).Path }
        Copy-Item "$scriptDir\OpenClawMonitor.exe" -Destination $script:installPath -Force
        Copy-Item "$scriptDir\Uninstall.exe" -Destination $script:installPath -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 300

        # Create shortcuts
        $script:statusLabel.Text = "Creating shortcuts..."
        $script:progressBar.Value = 55
        $form.Refresh()
        $ws = New-Object -ComObject WScript.Shell

        if ($script:createDesktopShortcut) {
            $desktop = [Environment]::GetFolderPath('Desktop')
            $shortcut = $ws.CreateShortcut("$desktop\OpenClaw Monitor.lnk")
            $shortcut.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $shortcut.WorkingDirectory = $script:installPath
            $shortcut.Description = "OpenClaw Bot Status Monitor"
            $shortcut.Save()
        }

        if ($script:createStartMenuShortcut) {
            $startMenu = [Environment]::GetFolderPath('Programs')
            $smFolder = "$startMenu\OpenClaw Monitor"
            if (!(Test-Path $smFolder)) { New-Item -ItemType Directory -Path $smFolder -Force | Out-Null }
            $shortcut = $ws.CreateShortcut("$smFolder\OpenClaw Monitor.lnk")
            $shortcut.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $shortcut.WorkingDirectory = $script:installPath
            $shortcut.Save()
            $unShortcut = $ws.CreateShortcut("$smFolder\Uninstall.lnk")
            $unShortcut.TargetPath = "$($script:installPath)\Uninstall.exe"
            $unShortcut.Save()
        }
        Start-Sleep -Milliseconds 300

        # Startup
        $script:statusLabel.Text = "Configuring startup options..."
        $script:progressBar.Value = 70
        $form.Refresh()
        if ($script:addToStartup) {
            $startup = [Environment]::GetFolderPath('Startup')
            $shortcut = $ws.CreateShortcut("$startup\OpenClaw Monitor.lnk")
            $shortcut.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $shortcut.WorkingDirectory = $script:installPath
            $shortcut.Save()
        }
        Start-Sleep -Milliseconds 300

        # Registry
        $script:statusLabel.Text = "Registering application..."
        $script:progressBar.Value = 85
        $form.Refresh()
        $uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenClawMonitor"
        New-Item -Path $uninstallKey -Force | Out-Null
        Set-ItemProperty -Path $uninstallKey -Name "DisplayName" -Value "OpenClaw Monitor"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayIcon" -Value "$($script:installPath)\OpenClawMonitor.exe"
        Set-ItemProperty -Path $uninstallKey -Name "UninstallString" -Value "$($script:installPath)\Uninstall.exe"
        Set-ItemProperty -Path $uninstallKey -Name "InstallLocation" -Value $script:installPath
        Set-ItemProperty -Path $uninstallKey -Name "Publisher" -Value "OpenClaw"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayVersion" -Value "1.0.6"
        Set-ItemProperty -Path $uninstallKey -Name "EstimatedSize" -Value 100
        Set-ItemProperty -Path $uninstallKey -Name "NoModify" -Value 1
        Set-ItemProperty -Path $uninstallKey -Name "NoRepair" -Value 1
        Start-Sleep -Milliseconds 300

        $script:progressBar.Value = 100
        $form.Refresh()
        Start-Sleep -Milliseconds 400

        # Show complete step
        Show-CompleteStep

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Installation failed: $($_.Exception.Message)", "Error", "OK", "Error")
        $form.Close()
    }
}

function Show-CompleteStep {
    $contentPanel.Controls.Clear()

    $progressLabel.Text = "Complete"
    $backBtn.Visible = $false
    $cancelBtn.Visible = $false
    $nextBtn.Text = "Finish"
    $nextBtn.Visible = $true

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Installation Complete!"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $check = New-Object System.Windows.Forms.Label
    $check.Text = [char]::ConvertFromUtf32(0x2705)
    $check.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 60)
    $check.Location = New-Object System.Drawing.Point(250, 70)
    $check.AutoSize = $true
    $contentPanel.Controls.Add($check)

    $info = New-Object System.Windows.Forms.Label
    $info.Text = "OpenClaw Monitor has been installed successfully.`n`nInstalled to:`n$($script:installPath)`n`nClick Finish to close this wizard."
    $info.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $info.Location = New-Object System.Drawing.Point(30, 180)
    $info.Size = New-Object System.Drawing.Size(540, 120)
    $contentPanel.Controls.Add($info)

    $form.Refresh()

    # Launch the app immediately if option was selected
    if ($script:launchAfter) {
        Start-Process "$($script:installPath)\OpenClawMonitor.exe"
    }
}

$nextBtn.Add_Click({
    if ($nextBtn.Text -eq "Finish") {
        $form.Close()
    } else {
        $script:currentStep++
        Show-Step $script:currentStep
    }
})

# Start
Show-Step 1
[void]$form.ShowDialog()
