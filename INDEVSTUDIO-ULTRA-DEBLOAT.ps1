# ==========================================================
#   ███╗   ██╗██████╗ ███████╗██████╗ ██╗   ██╗███████╗
#   ████╗  ██║██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝
#   ██╔██╗ ██║██████╔╝█████╗  ██████╔╝██║   ██║█████╗
#   ██║╚██╗██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██╔══╝
#   ██║ ╚████║██║     ███████╗██║  ██║╚██████╔╝███████╗
#   ╚═╝  ╚═══╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
#
#              INDEVSTUDIO ULTRA DEBLOAT v2.0
# ==========================================================

# --- Functions ---

function Show-Animation {
    param([string]$text)
    $frames = @("|","/","-","\")
    for ($i = 0; $i -lt 15; $i++) {
        $f = $frames[$i % $frames.Length]
        Write-Host "`r$f $text" -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
    }
    Write-Host ""
}

function Progress-Bar {
    param([string]$msg)
    Write-Host "$msg"
    for ($i = 0; $i -le 30; $i++) {
        $bar = "#" * $i
        Write-Host "`r[$bar" -NoNewline
        Start-Sleep -Milliseconds 35
    }
    Write-Host ""
}

function Safe-Debloat {
    Show-Animation "Removing Safe Bloat..."
    $apps = @(
        "Microsoft.3DBuilder","Microsoft.BingFinance","Microsoft.BingNews",
        "Microsoft.BingSports","Microsoft.BingWeather","Microsoft.GetHelp",
        "Microsoft.Getstarted","Microsoft.Microsoft3DViewer","Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection","Microsoft.MinecraftUWP",
        "Microsoft.MixedReality.Portal","Microsoft.OneConnect","Microsoft.People",
        "Microsoft.Print3D","Microsoft.SkypeApp","Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp","Microsoft.XboxGameOverlay","Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone","Microsoft.ZuneMusic","Microsoft.ZuneVideo"
    )
    foreach ($app in $apps) {
        Write-Host "Removing: $app"
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | where {$_.DisplayName -eq $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Write-Host "Keeping Microsoft Store..." -ForegroundColor Yellow
    Show-Animation "Safe Debloat Completed"
}

function Hardcore-Debloat {
    Progress-Bar "Activating HARDCORE MODE..."
    Show-Animation "Killing Telemetry..."
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Stop-Service dmwappushservice -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
    Set-Service dmwappushservice -StartupType Disabled
    Get-ScheduledTask | where {$_.TaskName -match "Telemetry|Customer Experience"} | Disable-ScheduledTask
    Show-Animation "Purging OneDrive..."
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    Start-Sleep 0.3
    & "$env:SYSTEMROOT\System32\OneDriveSetup.exe" /uninstall
    Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Show-Animation "Killing Cortana..."
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
    Show-Animation "Disabling Xbox system..."
    $svcX = @("XblAuthManager","XblGameSave","XboxNetApiSvc")
    foreach ($s in $svcX) {
        Stop-Service $s -ErrorAction SilentlyContinue
        Set-Service $s -StartupType Disabled
    }
    Show-Animation "Blocking All Windows Ads..."
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f
    Show-Animation "Disabling Windows Defender..."
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
}

function Performance-Tweaks {
    Show-Animation "Applying Performance Tweaks..."
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f
}

function Disable-Delivery-Optimization {
    Show-Animation "Disabling Delivery Optimization..."
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d 4 /f
}

function Advanced-Privacy-Tweaks {
    Show-Animation "Applying Advanced Privacy Tweaks..."
    $tasks = @(
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Application Experience\StartupAppTask",
        "\Microsoft\Windows\Autochk\Proxy",
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "\Microsoft\Windows\NetTrace\GatherNetworkInfo",
        "\Microsoft\Windows\PI\Sqm-Tasks"
    )
    foreach ($task in $tasks) {
        Get-ScheduledTask -TaskPath $task | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }
}

function Create-Restore-Point {
    Show-Animation "Creating System Restore Point..."
    Checkpoint-Computer -Description "INDEVSTUDIO-ULTRA-DEBLOAT" -RestorePointType "MODIFY_SETTINGS"
}

function Tools-Menu {
    Clear-Host
    Write-Host "--- Tools Menu ---" -ForegroundColor Yellow
    Write-Host "1. Disk Cleanup"
    Write-Host "2. System File Checker"
    Write-Host "3. Back to Main Menu"
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "1" { & cleanmgr.exe }
        "2" { & sfc.exe /scannow }
        "3" { return }
    }
}

# --- Main Menu ---

while ($true) {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "  INDEVSTUDIO ULTRA DEBLOAT v2.0" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "1. Safe Debloat"
    Write-Host "2. Hardcore Debloat"
    Write-Host "3. Performance Tweaks"
    Write-Host "4. Disable Delivery Optimization"
    Write-Host "5. Advanced Privacy Tweaks"
    Write-Host "6. Create System Restore Point"
    Write-Host "7. Tools Menu"
    Write-Host "8. Skip All"
    Write-Host "9. Exit"
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" { Safe-Debloat }
        "2" { Hardcore-Debloat }
        "3" { Performance-Tweaks }
        "4" { Disable-Delivery-Optimization }
        "5" { Advanced-Privacy-Tweaks }
        "6" { Create-Restore-Point }
        "7" { Tools-Menu }
        "8" { break }
        "9" { exit }
    }
    Pause
}
