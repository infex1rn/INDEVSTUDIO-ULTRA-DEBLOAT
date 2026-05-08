# ==========================================================
# ██████╗ ██╗ █████╗  ██████╗ ███████╗
# ██╔══██╗██║██╔══██╗██╔═══██╗██╔════╝
# ██║  ██║██║███████║██║   ██║███████╗
# ██║  ██║██║██╔══██║██║   ██║╚════██║
# ██████╔╝██║██║  ██║╚██████╔╝███████║
# ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
#
#     INDEVSTUDIO EXTREME DEV EDITION + XMODE
# ==========================================================
# PURPOSE:
# Extreme stripped developer workstation optimization
#
# FEATURES:
# - Telemetry kill
# - Windows update kill
# - Defender reduction
# - Edge removal
# - Store removal
# - AI/Copilot removal
# - Performance optimization
# - Hyper-V / WSL setup
# - Extreme power mode
#
# WARNING:
# USE AT YOUR OWN RISK.
# ==========================================================

# ==========================================================
# ADMIN CHECK
# ==========================================================

if (-NOT ([Security.Principal.WindowsPrincipal]
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host ""
    Write-Host "[-] RUN AS ADMINISTRATOR!" -ForegroundColor Red
    Pause
    exit
}

# ==========================================================
# VARIABLES
# ==========================================================

$LogFile = "$env:SystemDrive\INDEVSTUDIO-XMODE.log"

# ==========================================================
# LOGGING
# ==========================================================

function Log {

    param([string]$msg)

    $time = Get-Date -Format "HH:mm:ss"

    "$time - $msg" |
    Out-File $LogFile -Append
}

# ==========================================================
# ANIMATION
# ==========================================================

function Show-Animation {

    param([string]$text)

    $frames = @("|","/","-","\")

    for ($i = 0; $i -lt 12; $i++) {

        Write-Host "`r$($frames[$i % 4]) $text" `
        -NoNewline `
        -ForegroundColor Cyan

        Start-Sleep -Milliseconds 80
    }

    Write-Host ""

    Log $text
}

# ==========================================================
# BANNER
# ==========================================================

function Banner {

    Clear-Host

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "      INDEVSTUDIO EXTREME DEV XMODE"
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ==========================================================
# RESTORE POINT
# ==========================================================

function Create-Restore {

    Show-Animation "Creating Restore Point..."

    Enable-ComputerRestore `
    -Drive "C:\" `
    -ErrorAction SilentlyContinue

    Checkpoint-Computer `
    -Description "INDEVSTUDIO-XMODE" `
    -RestorePointType "MODIFY_SETTINGS"

    Log "Restore Point Created"
}

# ==========================================================
# TELEMETRY KILL
# ==========================================================

function Disable-Telemetry {

    Show-Animation "Destroying Telemetry..."

    $services = @(
        "DiagTrack",
        "dmwappushservice"
    )

    foreach ($svc in $services) {

        Stop-Service $svc `
        -Force `
        -ErrorAction SilentlyContinue

        Set-Service $svc `
        -StartupType Disabled `
        -ErrorAction SilentlyContinue
    }

    reg add `
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    /v AllowTelemetry `
    /t REG_DWORD `
    /d 0 /f

    Log "Telemetry Disabled"
}

# ==========================================================
# WINDOWS UPDATE KILL
# ==========================================================

function Disable-WindowsUpdate {

    Show-Animation "Destroying Windows Update..."

    $services = @(
        "wuauserv",
        "UsoSvc",
        "BITS",
        "WaaSMedicSvc"
    )

    foreach ($svc in $services) {

        Stop-Service $svc `
        -Force `
        -ErrorAction SilentlyContinue

        Set-Service $svc `
        -StartupType Disabled `
        -ErrorAction SilentlyContinue
    }

    reg add `
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    /v NoAutoUpdate `
    /t REG_DWORD `
    /d 1 /f

    Log "Windows Update Disabled"
}

# ==========================================================
# DEFENDER REDUCTION
# ==========================================================

function Disable-Defender {

    Show-Animation "Neutralizing Defender..."

    Set-MpPreference `
    -DisableRealtimeMonitoring $true `
    -ErrorAction SilentlyContinue

    Set-MpPreference `
    -DisableBehaviorMonitoring $true `
    -ErrorAction SilentlyContinue

    Set-MpPreference `
    -DisableScriptScanning $true `
    -ErrorAction SilentlyContinue

    Add-MpPreference `
    -ExclusionPath "C:\Dev" `
    -ErrorAction SilentlyContinue

    Add-MpPreference `
    -ExclusionPath "C:\VM" `
    -ErrorAction SilentlyContinue

    Add-MpPreference `
    -ExclusionPath "C:\Toolchains" `
    -ErrorAction SilentlyContinue

    Log "Defender Reduced"
}

# ==========================================================
# REMOVE BLOAT
# ==========================================================

function Remove-Bloat {

    Show-Animation "Removing Bloat..."

    $apps = @(

        "Microsoft.XboxApp",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",

        "Microsoft.YourPhone",
        "Microsoft.People",
        "Microsoft.SkypeApp",

        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",

        "Microsoft.GetHelp",
        "Microsoft.Getstarted",

        "Microsoft.BingWeather",
        "Microsoft.BingNews",

        "Microsoft.MixedReality.Portal",

        "Microsoft.OneConnect",

        "Microsoft.MicrosoftSolitaireCollection"
    )

    foreach ($app in $apps) {

        Write-Host "Removing: $app"

        Get-AppxPackage `
        -Name $app `
        -AllUsers |

        Remove-AppxPackage `
        -ErrorAction SilentlyContinue

        Get-AppxProvisionedPackage -Online |
        Where-Object {
            $_.DisplayName -eq $app
        } |

        Remove-AppxProvisionedPackage `
        -Online `
        -ErrorAction SilentlyContinue
    }

    Log "Bloat Removed"
}

# ==========================================================
# REMOVE EDGE + STORE
# ==========================================================

function Remove-EdgeStore {

    Show-Animation "Destroying Edge + Store..."

    taskkill /f /im msedge.exe 2>$null

    Get-AppxPackage *WindowsStore* |
    Remove-AppxPackage `
    -ErrorAction SilentlyContinue

    Get-AppxPackage *MicrosoftEdge* |
    Remove-AppxPackage `
    -ErrorAction SilentlyContinue

    Get-AppxPackage *WebExperience* |
    Remove-AppxPackage `
    -ErrorAction SilentlyContinue

    Log "Edge + Store Removed"
}

# ==========================================================
# DISABLE AI
# ==========================================================

function Disable-AI {

    Show-Animation "Destroying AI Features..."

    reg add `
    "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" `
    /v TurnOffWindowsCopilot `
    /t REG_DWORD `
    /d 1 /f

    reg add `
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    /v DisableConsumerFeatures `
    /t REG_DWORD `
    /d 1 /f

    Log "AI Disabled"
}

# ==========================================================
# EXTREME PERFORMANCE MODE
# ==========================================================

function Extreme-Performance {

    Show-Animation "Activating XMODE..."

    # Ultimate Performance
    powercfg -duplicatescheme `
    e9a42b02-d5df-448d-aa00-03f14749eb61

    $ultimate = (
        powercfg -list |
        Select-String "Ultimate Performance"
    ).ToString().Split()[3]

    powercfg -setactive $ultimate

    # CPU Boost
    powercfg -setacvalueindex `
    scheme_current `
    sub_processor `
    PROCTHROTTLEMIN 100

    powercfg -setacvalueindex `
    scheme_current `
    sub_processor `
    PROCTHROTTLEMAX 100

    powercfg -setacvalueindex `
    scheme_current `
    sub_processor `
    PERFBOOSTMODE 2

    # Disable CPU Core Parking
    powercfg -setacvalueindex `
    scheme_current `
    sub_processor `
    CPMINCORES 100

    # Disable Hibernation
    powercfg -hibernate off

    # Disable Dynamic Tick
    bcdedit /set disabledynamictick yes

    # Enable Platform Tick
    bcdedit /set useplatformtick yes

    # GPU Scheduling
    reg add `
    "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
    /v HwSchMode `
    /t REG_DWORD `
    /d 2 /f

    # Startup Delay Off
    reg add `
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
    /v StartupDelayInMSec `
    /t REG_DWORD `
    /d 0 /f

    Log "XMODE Enabled"
}

# ==========================================================
# PERFORMANCE TWEAKS
# ==========================================================

function Performance-Tweaks {

    Show-Animation "Applying Performance Tweaks..."

    reg add `
    "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" `
    /v LongPathsEnabled `
    /t REG_DWORD `
    /d 1 /f

    reg add `
    "HKCU\Control Panel\Desktop" `
    /v MenuShowDelay `
    /t REG_SZ `
    /d 0 /f

    reg add `
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    /v TaskbarAnimations `
    /t REG_DWORD `
    /d 0 /f

    Log "Performance Tweaks Applied"
}

# ==========================================================
# DEV FEATURES
# ==========================================================

function Enable-DevFeatures {

    Show-Animation "Enabling Dev Features..."

    Enable-WindowsOptionalFeature `
    -Online `
    -FeatureName Microsoft-Hyper-V-All `
    -NoRestart `
    -ErrorAction SilentlyContinue

    Enable-WindowsOptionalFeature `
    -Online `
    -FeatureName Microsoft-Windows-Subsystem-Linux `
    -NoRestart `
    -ErrorAction SilentlyContinue

    Enable-WindowsOptionalFeature `
    -Online `
    -FeatureName VirtualMachinePlatform `
    -NoRestart `
    -ErrorAction SilentlyContinue

    # Test Signing
    bcdedit /set testsigning on

    Log "Dev Features Enabled"
}

# ==========================================================
# DEV DIRECTORIES
# ==========================================================

function Create-DevFolders {

    Show-Animation "Creating Dev Environment..."

    $folders = @(

        "C:\Dev",
        "C:\VM",
        "C:\ISO",
        "C:\Toolchains",
        "C:\BuildCache"
    )

    foreach ($folder in $folders) {

        New-Item `
        -Path $folder `
        -ItemType Directory `
        -Force `
        -ErrorAction SilentlyContinue
    }

    Log "Dev Folders Created"
}

# ==========================================================
# CLEANUP
# ==========================================================

function Cleanup-System {

    Show-Animation "Cleaning System..."

    Remove-Item `
    "$env:TEMP\*" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

    Remove-Item `
    "C:\Windows\Temp\*" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

    Log "Cleanup Complete"
}

# ==========================================================
# MAIN
# ==========================================================

Banner

Write-Host "[+] STARTING EXTREME DEV OPTIMIZATION..."
Write-Host ""

Create-Restore
Disable-Telemetry
Disable-WindowsUpdate
Disable-Defender
Remove-Bloat
Remove-EdgeStore
Disable-AI
Extreme-Performance
Performance-Tweaks
Enable-DevFeatures
Create-DevFolders
Cleanup-System

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "        EXTREME DEV XMODE COMPLETE"
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Recommended:"
Write-Host "- Reboot System"
Write-Host "- Install Drivers"
Write-Host "- Install Toolchains"
Write-Host "- Monitor CPU Temps"

Write-Host ""
Pause
