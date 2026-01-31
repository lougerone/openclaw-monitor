# Build single installation package
# Embeds OpenClawMonitor.exe and Uninstall.exe into the installer

$scriptDir = "D:\OpenClaw\OpenClaw Monitor"

# Read and encode the EXE files
$monitorBytes = [IO.File]::ReadAllBytes("$scriptDir\OpenClawMonitor.exe")
$uninstallBytes = [IO.File]::ReadAllBytes("$scriptDir\Uninstall.exe")

$monitorB64 = [Convert]::ToBase64String($monitorBytes)
$uninstallB64 = [Convert]::ToBase64String($uninstallBytes)

Write-Host "Monitor.exe: $($monitorBytes.Length) bytes -> $($monitorB64.Length) base64 chars"
Write-Host "Uninstall.exe: $($uninstallBytes.Length) bytes -> $($uninstallB64.Length) base64 chars"

# Create the self-contained installer script
$installerScript = @'
# OpenClaw Monitor - Self-Contained Installer
# All files embedded - single download required

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:currentStep = 1
$script:installPath = "$env:LOCALAPPDATA\OpenClawMonitor"
$script:addToStartup = $true
$script:createDesktopShortcut = $true
$script:createStartMenuShortcut = $true
$script:launchAfter = $true

# EMBEDDED FILES (Base64)
$script:MonitorExeB64 = "@@MONITOR_B64@@"
$script:UninstallExeB64 = "@@UNINSTALL_B64@@"

# Main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenClaw Monitor Setup"
$form.Size = New-Object System.Drawing.Size(550, 450)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Header panel
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

# Content panel
$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Size = New-Object System.Drawing.Size(550, 290)
$contentPanel.Location = New-Object System.Drawing.Point(0, 70)
$contentPanel.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($contentPanel)

# Footer panel
$footerPanel = New-Object System.Windows.Forms.Panel
$footerPanel.Size = New-Object System.Drawing.Size(550, 60)
$footerPanel.Location = New-Object System.Drawing.Point(0, 360)
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
$cancelBtn.Size = New-Object System.Drawing.Size(80, 30)
$cancelBtn.Location = New-Object System.Drawing.Point(260, 15)
$cancelBtn.Add_Click({ $form.Close() })
$footerPanel.Controls.Add($cancelBtn)

$backBtn = New-Object System.Windows.Forms.Button
$backBtn.Text = "< Back"
$backBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$backBtn.Size = New-Object System.Drawing.Size(80, 30)
$backBtn.Location = New-Object System.Drawing.Point(350, 15)
$backBtn.Add_Click({ $script:currentStep--; Show-Step $script:currentStep })
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
    if ($step -eq 4) { $nextBtn.Visible = $false }
    elseif ($step -eq 5) { $nextBtn.Text = "Finish"; $nextBtn.Visible = $true }
    else { $nextBtn.Text = "Next >"; $nextBtn.Visible = $true }
}

function Show-WelcomeStep {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Welcome to OpenClaw Monitor"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "This wizard will install OpenClaw Monitor on your computer.`n`nOpenClaw Monitor is a system tray utility that shows whether`nyour OpenClaw bot is online or offline.`n`nFeatures:`n`n  - Real-time status indicator (green/red)`n  - Desktop notifications when status changes`n  - Quick access to dashboard and logs`n  - One-click gateway restart`n`nClick Next to continue."
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $desc.Location = New-Object System.Drawing.Point(30, 55)
    $desc.Size = New-Object System.Drawing.Size(480, 220)
    $contentPanel.Controls.Add($desc)
}

function Show-LocationStep {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Choose Install Location"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $desc = New-Object System.Windows.Forms.Label
    $desc.Text = "Select the folder where OpenClaw Monitor will be installed:"
    $desc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $desc.Location = New-Object System.Drawing.Point(30, 55)
    $desc.AutoSize = $true
    $contentPanel.Controls.Add($desc)

    $script:pathBox = New-Object System.Windows.Forms.TextBox
    $script:pathBox.Text = $script:installPath
    $script:pathBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:pathBox.Location = New-Object System.Drawing.Point(30, 90)
    $script:pathBox.Size = New-Object System.Drawing.Size(380, 28)
    $contentPanel.Controls.Add($script:pathBox)

    $browseBtn = New-Object System.Windows.Forms.Button
    $browseBtn.Text = "Browse..."
    $browseBtn.Location = New-Object System.Drawing.Point(420, 89)
    $browseBtn.Size = New-Object System.Drawing.Size(80, 28)
    $browseBtn.Add_Click({
        $fb = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($fb.ShowDialog() -eq "OK") { $script:pathBox.Text = $fb.SelectedPath }
    })
    $contentPanel.Controls.Add($browseBtn)

    $space = New-Object System.Windows.Forms.Label
    $space.Text = "Space required: ~1 MB"
    $space.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $space.ForeColor = [System.Drawing.Color]::Gray
    $space.Location = New-Object System.Drawing.Point(30, 130)
    $space.AutoSize = $true
    $contentPanel.Controls.Add($space)
}

function Show-OptionsStep {
    $script:installPath = $script:pathBox.Text

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Installation Options"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $script:desktopCheck = New-Object System.Windows.Forms.CheckBox
    $script:desktopCheck.Text = "Create desktop shortcut"
    $script:desktopCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:desktopCheck.Location = New-Object System.Drawing.Point(30, 70)
    $script:desktopCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:desktopCheck.Checked = $true
    $contentPanel.Controls.Add($script:desktopCheck)

    $script:startMenuCheck = New-Object System.Windows.Forms.CheckBox
    $script:startMenuCheck.Text = "Create Start Menu shortcut"
    $script:startMenuCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:startMenuCheck.Location = New-Object System.Drawing.Point(30, 105)
    $script:startMenuCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:startMenuCheck.Checked = $true
    $contentPanel.Controls.Add($script:startMenuCheck)

    $script:startupCheck = New-Object System.Windows.Forms.CheckBox
    $script:startupCheck.Text = "Start with Windows"
    $script:startupCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:startupCheck.Location = New-Object System.Drawing.Point(30, 140)
    $script:startupCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:startupCheck.Checked = $true
    $contentPanel.Controls.Add($script:startupCheck)

    $script:launchCheck = New-Object System.Windows.Forms.CheckBox
    $script:launchCheck.Text = "Launch after installation"
    $script:launchCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:launchCheck.Location = New-Object System.Drawing.Point(30, 175)
    $script:launchCheck.Size = New-Object System.Drawing.Size(300, 25)
    $script:launchCheck.Checked = $true
    $contentPanel.Controls.Add($script:launchCheck)

    $nextBtn.Text = "Install"
}

function Show-InstallStep {
    $script:createDesktopShortcut = $script:desktopCheck.Checked
    $script:createStartMenuShortcut = $script:startMenuCheck.Checked
    $script:addToStartup = $script:startupCheck.Checked
    $script:launchAfter = $script:launchCheck.Checked

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Installing..."
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $script:statusLabel = New-Object System.Windows.Forms.Label
    $script:statusLabel.Text = "Preparing..."
    $script:statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:statusLabel.Location = New-Object System.Drawing.Point(30, 60)
    $script:statusLabel.Size = New-Object System.Drawing.Size(480, 25)
    $contentPanel.Controls.Add($script:statusLabel)

    $script:progressBar = New-Object System.Windows.Forms.ProgressBar
    $script:progressBar.Location = New-Object System.Drawing.Point(30, 100)
    $script:progressBar.Size = New-Object System.Drawing.Size(480, 25)
    $contentPanel.Controls.Add($script:progressBar)

    $form.Refresh()

    try {
        # Create directory
        $script:statusLabel.Text = "Creating directory..."
        $script:progressBar.Value = 15
        $form.Refresh()
        if (!(Test-Path $script:installPath)) {
            New-Item -ItemType Directory -Path $script:installPath -Force | Out-Null
        }
        Start-Sleep -Milliseconds 200

        # Extract files
        $script:statusLabel.Text = "Extracting files..."
        $script:progressBar.Value = 35
        $form.Refresh()
        [IO.File]::WriteAllBytes("$($script:installPath)\OpenClawMonitor.exe", [Convert]::FromBase64String($script:MonitorExeB64))
        [IO.File]::WriteAllBytes("$($script:installPath)\Uninstall.exe", [Convert]::FromBase64String($script:UninstallExeB64))
        Start-Sleep -Milliseconds 200

        # Create shortcuts
        $script:statusLabel.Text = "Creating shortcuts..."
        $script:progressBar.Value = 55
        $form.Refresh()
        $ws = New-Object -ComObject WScript.Shell

        if ($script:createDesktopShortcut) {
            $s = $ws.CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\OpenClaw Monitor.lnk")
            $s.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $s.Save()
        }

        if ($script:createStartMenuShortcut) {
            $smFolder = "$([Environment]::GetFolderPath('Programs'))\OpenClaw Monitor"
            if (!(Test-Path $smFolder)) { New-Item -ItemType Directory -Path $smFolder -Force | Out-Null }
            $s = $ws.CreateShortcut("$smFolder\OpenClaw Monitor.lnk")
            $s.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $s.Save()
            $u = $ws.CreateShortcut("$smFolder\Uninstall.lnk")
            $u.TargetPath = "$($script:installPath)\Uninstall.exe"
            $u.Save()
        }

        if ($script:addToStartup) {
            $s = $ws.CreateShortcut("$([Environment]::GetFolderPath('Startup'))\OpenClaw Monitor.lnk")
            $s.TargetPath = "$($script:installPath)\OpenClawMonitor.exe"
            $s.Save()
        }
        Start-Sleep -Milliseconds 200

        # Registry
        $script:statusLabel.Text = "Registering..."
        $script:progressBar.Value = 80
        $form.Refresh()
        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenClawMonitor"
        New-Item -Path $key -Force | Out-Null
        Set-ItemProperty -Path $key -Name "DisplayName" -Value "OpenClaw Monitor"
        Set-ItemProperty -Path $key -Name "DisplayIcon" -Value "$($script:installPath)\OpenClawMonitor.exe"
        Set-ItemProperty -Path $key -Name "UninstallString" -Value "$($script:installPath)\Uninstall.exe"
        Set-ItemProperty -Path $key -Name "InstallLocation" -Value $script:installPath
        Set-ItemProperty -Path $key -Name "Publisher" -Value "OpenClaw"
        Set-ItemProperty -Path $key -Name "DisplayVersion" -Value "1.0.5"
        Start-Sleep -Milliseconds 200

        $script:progressBar.Value = 100
        $form.Refresh()
        Start-Sleep -Milliseconds 300

        Show-Step 5
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Installation failed: $($_.Exception.Message)", "Error", "OK", "Error")
        $form.Close()
    }
}

function Show-CompleteStep {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Installation Complete!"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
    $lbl.Location = New-Object System.Drawing.Point(30, 20)
    $lbl.AutoSize = $true
    $contentPanel.Controls.Add($lbl)

    $check = New-Object System.Windows.Forms.Label
    $check.Text = [char]::ConvertFromUtf32(0x2705)
    $check.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 48)
    $check.Location = New-Object System.Drawing.Point(220, 70)
    $check.AutoSize = $true
    $contentPanel.Controls.Add($check)

    $info = New-Object System.Windows.Forms.Label
    $info.Text = "OpenClaw Monitor has been installed successfully.`n`nInstalled to: $($script:installPath)`n`nClick Finish to close."
    $info.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $info.Location = New-Object System.Drawing.Point(30, 160)
    $info.Size = New-Object System.Drawing.Size(480, 100)
    $contentPanel.Controls.Add($info)

    $progressLabel.Text = "Complete"
    $backBtn.Visible = $false
    $cancelBtn.Visible = $false
}

$nextBtn.Add_Click({
    if ($script:currentStep -eq 5) {
        if ($script:launchAfter) { Start-Process "$($script:installPath)\OpenClawMonitor.exe" }
        $form.Close()
    } else {
        $script:currentStep++
        Show-Step $script:currentStep
    }
})

Show-Step 1
[void]$form.ShowDialog()
'@

# Replace placeholders with actual base64 data
$installerScript = $installerScript -replace '@@MONITOR_B64@@', $monitorB64
$installerScript = $installerScript -replace '@@UNINSTALL_B64@@', $uninstallB64

# Save the self-contained installer
$installerScript | Out-File -FilePath "$scriptDir\SelfContainedInstaller.ps1" -Encoding UTF8

Write-Host "`nSelf-contained installer created: SelfContainedInstaller.ps1"
Write-Host "File size: $((Get-Item "$scriptDir\SelfContainedInstaller.ps1").Length) bytes"
