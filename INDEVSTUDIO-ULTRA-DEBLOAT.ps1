# ==========================================================
#   ███╗   ██╗██████╗ ███████╗██████╗ ██╗   ██╗███████╗
#   ████╗  ██║██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝
#   ██╔██╗ ██║██████╔╝█████╗  ██████╔╝██║   ██║█████╗  
#   ██║╚██╗██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██╔══╝  
#   ██║ ╚████║██║     ███████╗██║  ██║╚██████╔╝███████╗
#   ╚═╝  ╚═══╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
#
#              INDEVSTUDIO ULTRA DEBLOAT v1.0
# ==========================================================

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

Clear-Host
Show-Animation "Loading INDEVSTUDIO ULTRA DEBLOAT..."
Progress-Bar "Initializing engine..."

Write-Host "Starting Windows 10 Debloat..." -ForegroundColor Green
Start-Sleep -Milliseconds 400

# ==========================================================
# SAFE DEBLOAT (Your original safe list)
# ==========================================================

Show-Animation "Removing Safe Bloat..."

$apps = @(
    "Microsoft.3DBuilder","Microsoft.BingFinance","Microsoft.BingNews",
    "Microsoft.BingSports","Microsoft.BingWeather","Microsoft.GetHelp",
    "Microsoft.Getstarted","Microsoft.Microsoft3DViewer","Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection","Microsoft.MinecraftUWP",
    "Microsoft.MixedReality.Portal","Microsoft.OneConnect","Microsoft.People",
    "Microsoft.Print3D","Microsoft.SkypeApp","Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay","Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay","Microsoft.YourPhone",
    "Microsoft.ZuneMusic","Microsoft.ZuneVideo"
)

foreach ($app in $apps) {
    Write-Host "Removing: $app"
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | where {$_.DisplayName -eq $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "Keeping Microsoft Store..." -ForegroundColor Yellow
Show-Animation "Safe Debloat Completed"

# ==========================================================
#   HARDCORE DEBLOAT ZONE (EXTREME MODE)
# ==========================================================

Progress-Bar "Activating HARDCORE MODE..."

# --- Disable Telemetry Engines ---
Show-Animation "Killing Telemetry..."

Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
Stop-Service dmwappushservice -Force -ErrorAction SilentlyContinue
Set-Service DiagTrack -StartupType Disabled
Set-Service dmwappushservice -StartupType Disabled

# Disable ALL telemetry scheduled tasks
Get-ScheduledTask | where {$_.TaskName -match "Telemetry|Customer Experience"} | Disable-ScheduledTask

# --- Remove OneDrive Completely ---
Show-Animation "Purging OneDrive..."

Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
Start-Sleep 0.3
& "$env:SYSTEMROOT\System32\OneDriveSetup.exe" /uninstall
Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue

# --- Disable Cortana ---
Show-Animation "Killing Cortana..."
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f

# --- Disable Xbox & Gaming ---
Show-Animation "Disabling Xbox system..."
$svcX = @("XblAuthManager","XblGameSave","XboxNetApiSvc")
foreach ($s in $svcX) {
    Stop-Service $s -ErrorAction SilentlyContinue
    Set-Service $s -StartupType Disabled
}

# --- Disable Ads, Suggestions, Noise ---
Show-Animation "Blocking All Windows Ads..."

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f

# --- Disable Windows Defender (Hardcore) ---
Show-Animation "Disabling Windows Defender..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f

# ==========================================================
# Performance Tweaks
# ==========================================================

Show-Animation "Applying Performance Tweaks..."

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f

# ==========================================================
# Cleanup
# ==========================================================

Show-Animation "Cleaning Temporary Files..."

Remove-Item "C:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue

# ==========================================================
# DONE
# ==========================================================

Progress-Bar "Finalizing..."

Write-Host "`nINDEVSTUDIO ULTRA DEBLOAT Completed Successfully!" -ForegroundColor Green
Write-Host "Restart your PC to apply all changes." -ForegroundColor Cyan
