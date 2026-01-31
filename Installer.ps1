# OpenClaw Monitor Installer - Multi-Step Wizard

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:currentStep = 1
$script:installPath = "$env:LOCALAPPDATA\OpenClawMonitor"
$script:addToStartup = $true
$script:createDesktopShortcut = $true
$script:createStartMenuShortcut = $true
$script:launchAfter = $true

# Main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenClaw Monitor Setup"
$form.Size = New-Object System.Drawing.Size(550, 450)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Header panel (consistent across steps)
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(550, 70)
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

# Content panel (changes per step)
$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Size = New-Object System.Drawing.Size(550, 290)
$contentPanel.Location = New-Object System.Drawing.Point(0, 70)
$contentPanel.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($contentPanel)

# Footer panel with buttons
$footerPanel = New-Object System.Windows.Forms.Panel
$footerPanel.Size = New-Object System.Drawing.Size(550, 60)
$footerPanel.Location = New-Object System.Drawing.Point(0, 360)
$footerPanel.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Controls.Add($footerPanel)

# Progress indicator
$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$progressLabel.ForeColor = [System.Drawing.Color]::Gray
$progressLabel.Location = New-Object System.Drawing.Point(20, 20)
$progressLabel.AutoSize = $true
$footerPanel.Controls.Add($progressLabel)

# Buttons
$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Cancel"
$cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$cancelBtn.Size = New-Object System.Drawing.Size(80, 30)
$cancelBtn.Location = New-Object System.Drawing.Point(260, 15)
$cancelBtn.Add_Click({ $form.Close() })
$footerPanel.Controls.Add($cancelBtn)

$backBtn = New-Object System.Windows.Forms.Button
$backBtn.Text = "< Back"
$backBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$backBtn.Size = New-Object System.Drawing.Size(80, 30)
$backBtn.Location = New-Object System.Drawing.Point(350, 15)
$backBtn.Add_Click({
    $script:currentStep--
    Show-Step $script:currentStep
})
$footerPanel.Controls.Add($backBtn)

$nextBtn = New-Object System.Windows.Forms.Button
$nextBtn.Text = "Next >"
$nextBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$nextBtn.Size = New-Object System.Drawing.Size(80, 30)
$nextBtn.Location = New-Object System.Drawing.Point(440, 15)
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
        5 { Show-CompleteStep }
    }

    $progressLabel.Text = "Step $step of 5"
    $backBtn.Enabled = ($step -gt 1 -and $step -lt 4)
    $backBtn.Visible = ($step -lt 4)
    $cancelBtn.Visible = ($step -lt 4)

    if ($step -eq 4) {
        $nextBtn.Visible = $false
    } elseif ($step -eq 5) {
        $nextBtn.Text = "Finish"
        $nextBtn.Visible = $true
    } else {
        $nextBtn.Text = "Next >"
        $nextBtn.Visible = $true
    }
}

function Show-WelcomeStep {
    $welcomeLabel = New-Object System.Windows.Forms.Label
    $welcomeLabel.Text = "Welcome to OpenClaw Monitor"
    $welcomeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $welcomeLabel.Location = New-Object System.Drawing.Point(30, 20)
    $welcomeLabel.AutoSize = $true
    $contentPanel.Controls.Add($welcomeLabel)

    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = "This wizard will install OpenClaw Monitor on your computer.`n`nOpenClaw Monitor is a system tray utility that shows you whether`nyour OpenClaw bot is online or offline.`n`n`nFeatures:`n`n   `u{2022}  Real-time status indicator (green/red)`n   `u{2022}  Desktop notifications when status changes`n   `u{2022}  Quick access to dashboard and logs`n   `u{2022}  One-click gateway restart`n`n`nClick Next to continue."
    $descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $descLabel.Location = New-Object System.Drawing.Point(30, 55)
    $descLabel.Size = New-Object System.Drawing.Size(480, 220)
    $contentPanel.Controls.Add($descLabel)

    $nextBtn.Text = "Next >"
}

function Show-LocationStep {
    $locLabel = New-Object System.Windows.Forms.Label
    $locLabel.Text = "Choose Install Location"
    $locLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $locLabel.Location = New-Object System.Drawing.Point(30, 20)
    $locLabel.AutoSize = $true
    $contentPanel.Controls.Add($locLabel)

    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = "Select the folder where OpenClaw Monitor will be installed:"
    $descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $descLabel.Location = New-Object System.Drawing.Point(30, 55)
    $descLabel.AutoSize = $true
    $contentPanel.Controls.Add($descLabel)

    $script:pathBox = New-Object System.Windows.Forms.TextBox
    $script:pathBox.Text = $script:installPath
    $script:pathBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:pathBox.Location = New-Object System.Drawing.Point(30, 90)
    $script:pathBox.Size = New-Object System.Drawing.Size(380, 28)
    $contentPanel.Controls.Add($script:pathBox)

    $browseBtn = New-Object System.Windows.Forms.Button
    $browseBtn.Text = "Browse..."
    $browseBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $browseBtn.Location = New-Object System.Drawing.Point(420, 89)
    $browseBtn.Size = New-Object System.Drawing.Size(80, 28)
    $browseBtn.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select installation folder"
        if ($folderBrowser.ShowDialog() -eq "OK") {
            $script:pathBox.Text = $folderBrowser.SelectedPath
        }
    })
    $contentPanel.Controls.Add($browseBtn)

    $spaceLabel = New-Object System.Windows.Forms.Label
    $spaceLabel.Text = "Space required: ~1 MB"
    $spaceLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $spaceLabel.ForeColor = [System.Drawing.Color]::Gray
    $spaceLabel.Location = New-Object System.Drawing.Point(30, 130)
    $spaceLabel.AutoSize = $true
    $contentPanel.Controls.Add($spaceLabel)
}

function Show-OptionsStep {
    $optLabel = New-Object System.Windows.Forms.Label
    $optLabel.Text = "Installation Options"
    $optLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $optLabel.Location = New-Object System.Drawing.Point(30, 20)
    $optLabel.AutoSize = $true
    $contentPanel.Controls.Add($optLabel)

    $script:installPath = $script:pathBox.Text

    $script:desktopCheck = New-Object System.Windows.Forms.CheckBox
    $script:desktopCheck.Text = "Create desktop shortcut"
    $script:desktopCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:desktopCheck.Location = New-Object System.Drawing.Point(30, 70)
    $script:desktopCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:desktopCheck.Checked = $script:createDesktopShortcut
    $contentPanel.Controls.Add($script:desktopCheck)

    $script:startMenuCheck = New-Object System.Windows.Forms.CheckBox
    $script:startMenuCheck.Text = "Create Start Menu shortcut"
    $script:startMenuCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:startMenuCheck.Location = New-Object System.Drawing.Point(30, 105)
    $script:startMenuCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:startMenuCheck.Checked = $script:createStartMenuShortcut
    $contentPanel.Controls.Add($script:startMenuCheck)

    $script:startupCheck = New-Object System.Windows.Forms.CheckBox
    $script:startupCheck.Text = "Start with Windows"
    $script:startupCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:startupCheck.Location = New-Object System.Drawing.Point(30, 140)
    $script:startupCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:startupCheck.Checked = $script:addToStartup
    $contentPanel.Controls.Add($script:startupCheck)

    $script:launchCheck = New-Object System.Windows.Forms.CheckBox
    $script:launchCheck.Text = "Launch OpenClaw Monitor after installation"
    $script:launchCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:launchCheck.Location = New-Object System.Drawing.Point(30, 175)
    $script:launchCheck.Size = New-Object System.Drawing.Size(350, 25)
    $script:launchCheck.Checked = $script:launchAfter
    $contentPanel.Controls.Add($script:launchCheck)

    $nextBtn.Text = "Install"
}

function Show-InstallStep {
    # Save options
    $script:createDesktopShortcut = $script:desktopCheck.Checked
    $script:createStartMenuShortcut = $script:startMenuCheck.Checked
    $script:addToStartup = $script:startupCheck.Checked
    $script:launchAfter = $script:launchCheck.Checked

    $instLabel = New-Object System.Windows.Forms.Label
    $instLabel.Text = "Installing..."
    $instLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $instLabel.Location = New-Object System.Drawing.Point(30, 20)
    $instLabel.AutoSize = $true
    $contentPanel.Controls.Add($instLabel)

    $script:statusLabel = New-Object System.Windows.Forms.Label
    $script:statusLabel.Text = "Preparing installation..."
    $script:statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:statusLabel.Location = New-Object System.Drawing.Point(30, 60)
    $script:statusLabel.Size = New-Object System.Drawing.Size(480, 25)
    $contentPanel.Controls.Add($script:statusLabel)

    $script:progressBar = New-Object System.Windows.Forms.ProgressBar
    $script:progressBar.Location = New-Object System.Drawing.Point(30, 100)
    $script:progressBar.Size = New-Object System.Drawing.Size(480, 25)
    $script:progressBar.Style = "Continuous"
    $contentPanel.Controls.Add($script:progressBar)

    $form.Refresh()

    # Do installation
    try {
        $steps = 6
        $current = 0

        # Step 1: Create directory
        $script:statusLabel.Text = "Creating installation directory..."
        $script:progressBar.Value = [int](++$current / $steps * 100)
        $form.Refresh()
        if (!(Test-Path $script:installPath)) {
            New-Item -ItemType Directory -Path $script:installPath -Force | Out-Null
        }
        Start-Sleep -Milliseconds 300

        # Step 2: Copy files
        $script:statusLabel.Text = "Copying files..."
        $script:progressBar.Value = [int](++$current / $steps * 100)
        $form.Refresh()
        $scriptDir = $PSScriptRoot
        if (!$scriptDir) { $scriptDir = (Get-Location).Path }
        Copy-Item "$scriptDir\OpenClawMonitor.exe" -Destination $script:installPath -Force
        Copy-Item "$scriptDir\Uninstall.exe" -Destination $script:installPath -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 300

        # Step 3: Create shortcuts
        $script:statusLabel.Text = "Creating shortcuts..."
        $script:progressBar.Value = [int](++$current / $steps * 100)
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

        # Step 4: Startup
        $script:statusLabel.Text = "Configuring startup..."
        $script:progressBar.Value = [int](++$current / $steps * 100)
        $form.Refresh()
        if ($script:addToStartup) {
            $startup = [Environment]::GetFolderPath('Startup')
            $shortcut = $ws.CreateShortcut("$startup\OpenClaw Monitor.lnk")
            $shortcut.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $shortcut.WorkingDirectory = $script:installPath
            $shortcut.Save()
        }
        Start-Sleep -Milliseconds 300

        # Step 5: Registry
        $script:statusLabel.Text = "Registering application..."
        $script:progressBar.Value = [int](++$current / $steps * 100)
        $form.Refresh()
        $uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenClawMonitor"
        New-Item -Path $uninstallKey -Force | Out-Null
        Set-ItemProperty -Path $uninstallKey -Name "DisplayName" -Value "OpenClaw Monitor"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayIcon" -Value "$($script:installPath)\OpenClawMonitor.exe"
        Set-ItemProperty -Path $uninstallKey -Name "UninstallString" -Value "$($script:installPath)\Uninstall.exe"
        Set-ItemProperty -Path $uninstallKey -Name "InstallLocation" -Value $script:installPath
        Set-ItemProperty -Path $uninstallKey -Name "Publisher" -Value "OpenClaw"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayVersion" -Value "1.0.3"
        Set-ItemProperty -Path $uninstallKey -Name "EstimatedSize" -Value 100
        Set-ItemProperty -Path $uninstallKey -Name "NoModify" -Value 1
        Set-ItemProperty -Path $uninstallKey -Name "NoRepair" -Value 1
        Start-Sleep -Milliseconds 300

        # Step 6: Complete
        $script:statusLabel.Text = "Completing installation..."
        $script:progressBar.Value = 100
        $form.Refresh()
        Start-Sleep -Milliseconds 500

        $script:currentStep = 5
        Show-Step 5

    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Installation failed: $($_.Exception.Message)",
            "Error",
            "OK",
            "Error"
        )
        $form.Close()
    }
}

function Show-CompleteStep {
    $doneLabel = New-Object System.Windows.Forms.Label
    $doneLabel.Text = "Installation Complete!"
    $doneLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $doneLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $doneLabel.Location = New-Object System.Drawing.Point(30, 20)
    $doneLabel.AutoSize = $true
    $contentPanel.Controls.Add($doneLabel)

    $checkLabel = New-Object System.Windows.Forms.Label
    $checkLabel.Text = [char]::ConvertFromUtf32(0x2705)
    $checkLabel.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 48)
    $checkLabel.Location = New-Object System.Drawing.Point(220, 70)
    $checkLabel.AutoSize = $true
    $contentPanel.Controls.Add($checkLabel)

    $infoLabel = New-Object System.Windows.Forms.Label
    $infoLabel.Text = "OpenClaw Monitor has been installed successfully.`n`nInstalled to: $($script:installPath)`n`nClick Finish to close this wizard."
    $infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $infoLabel.Location = New-Object System.Drawing.Point(30, 160)
    $infoLabel.Size = New-Object System.Drawing.Size(480, 100)
    $contentPanel.Controls.Add($infoLabel)

    $progressLabel.Text = "Complete"
    $backBtn.Visible = $false
    $cancelBtn.Visible = $false
}

$nextBtn.Add_Click({
    if ($script:currentStep -eq 5) {
        if ($script:launchAfter) {
            Start-Process "$($script:installPath)\OpenClawMonitor.exe"
        }
        $form.Close()
    } else {
        $script:currentStep++
        Show-Step $script:currentStep
    }
})

# Start at step 1
Show-Step 1

[void]$form.ShowDialog()
