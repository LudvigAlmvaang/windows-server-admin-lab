<#
.SYNOPSIS
    Runs all setup scripts for the Windows Server Admin Lab in two phases, handling required reboot after DC promotion.
.DESCRIPTION
    This script automates the execution of all major setup scripts for lab deployment. Run as Administrator.
    Phase 1: Installs roles and promotes to domain controller, then prompts for reboot and schedules itself to continue.
    Phase 2: After reboot, completes OU, user, and GPO setup, then removes the scheduled task.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-13
#>

# Define script paths
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptSelf = $MyInvocation.MyCommand.Definition
$TaskName = "WinLab-ContinueSetup"
$LogFile = Join-Path $ScriptRoot "Run-All-Setup.log"
$Phase1 = @("Install-ServerRoles.ps1")
$Phase2 = @(
    "Bulk-OU-Creation.ps1",
    "Create-ADUsers.ps1",
    "Configure-GPO.ps1"
)

# Start transcript for logging
Start-Transcript -Path $LogFile -Append

# Check if AD DS is already installed and this is post-reboot
$adInstalled = Get-WindowsFeature -Name AD-Domain-Services | Where-Object { $_.InstallState -eq 'Installed' }
$dc = $null
Try {
    $dc = Get-ADDomainController -ErrorAction Stop
} Catch {}

function Remove-ContinueTask {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed scheduled task: $TaskName" -ForegroundColor Yellow
    }
}

if (-not $adInstalled -or -not $dc) {
    # Phase 1: Install roles and promote to DC
    foreach ($Script in $Phase1) {
        $ScriptPath = Join-Path $ScriptRoot $Script
        if (Test-Path $ScriptPath) {
            Write-Host "Running $Script..." -ForegroundColor Cyan
            Try {
                & $ScriptPath
            } Catch {
                Write-Warning 'Error running ' +  $Script + ': ' + $_.Exception.Message
                Exit 1
            }
        } else {
            Write-Warning "$Script not found at $ScriptPath. Skipping."
        }
    }
    # Register scheduled task to continue after reboot
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptSelf`""
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -RunLevel Highest -Force
    Write-Host "Phase 1 complete. The server will now reboot and continue setup automatically." -ForegroundColor Yellow
    Stop-Transcript
    Restart-Computer -Force
    Exit 0
}

# Phase 2: Continue with OU, user, and GPO setup
foreach ($Script in $Phase2) {
    $ScriptPath = Join-Path $ScriptRoot $Script
    if (Test-Path $ScriptPath) {
        Write-Host "Running $Script..." -ForegroundColor Cyan
        Try {
            & $ScriptPath
        } Catch {
            Write-Warning 'Error running ' +  $Script + ': ' + $_.Exception.Message
            Exit 1
        }
    } else {
        Write-Warning "$Script not found at $ScriptPath. Skipping."
    }
}

Remove-ContinueTask
Write-Host "All setup scripts completed." -ForegroundColor Green
Stop-Transcript
