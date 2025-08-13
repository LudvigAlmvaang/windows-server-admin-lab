<#
.SYNOPSIS
    Runs all setup scripts for the Windows Server Admin Lab in two phases, handling required reboot after DC promotion.
.DESCRIPTION
    This script automates the execution of all major setup scripts for lab deployment. Run as Administrator.
    Phase 1: Installs roles and promotes to domain controller, then prompts for reboot.
    Phase 2: After reboot, completes OU, user, and GPO setup.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-13
#>

# Define script paths
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Phase1 = @("Install-ServerRoles.ps1")
$Phase2 = @(
    "Bulk-OU-Creation.ps1",
    "Create-ADUsers.ps1",
    "Configure-GPO.ps1"
)

# Check if AD DS is already installed and this is post-reboot
$adInstalled = Get-WindowsFeature -Name AD-Domain-Services | Where-Object { $_.InstallState -eq 'Installed' }
$dc = $null
Try {
    $dc = Get-ADDomainController -ErrorAction Stop
} Catch {}

if (-not $adInstalled -or -not $dc) {
    # Phase 1: Install roles and promote to DC
    foreach ($Script in $Phase1) {
        $ScriptPath = Join-Path $ScriptRoot $Script
        if (Test-Path $ScriptPath) {
            Write-Host "Running $Script..." -ForegroundColor Cyan
            Try {
                & $ScriptPath
            } Catch {
                Write-Warning ("Error running $Script: " + ($_ | Out-String))
                Exit 1
            }
        } else {
            Write-Warning "$Script not found at $ScriptPath. Skipping."
        }
    }
    Write-Host "Phase 1 complete. Please reboot the server, then rerun this script to continue with Phase 2." -ForegroundColor Yellow
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

Write-Host "All setup scripts completed." -ForegroundColor Green
