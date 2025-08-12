<#
.SYNOPSIS
    Runs all setup scripts for the Windows Server Admin Lab in the correct order.
.DESCRIPTION
    This script automates the execution of all major setup scripts for lab deployment. Run as Administrator.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-12
#>

# Define script paths
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Scripts = @(
    "Install-ServerRoles.ps1",
    "Bulk-OU-Creation.ps1",
    "Create-ADUsers.ps1",
    "Configure-GPO.ps1"
)

foreach ($Script in $Scripts) {
    $ScriptPath = Join-Path $ScriptRoot $Script
    if (Test-Path $ScriptPath) {
        Write-Host "Running $Script..." -ForegroundColor Cyan
        Try {
            & $ScriptPath
        } Catch {
            Write-Warning "Error running $Script: $_"
            Exit 1
        }
    } else {
        Write-Warning "$Script not found at $ScriptPath. Skipping."
    }
}

Write-Host "All setup scripts completed." -ForegroundColor Green
