<#
.SYNOPSIS
    Restores Group Policy Objects (GPOs) from backup XML files.
.DESCRIPTION
    This script restores GPOs from backup files in the GPO_Backups folder and links them to the appropriate OUs or domain.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-13
#>

# Variables
$BackupFolder = "../GPO_Backups"
$DomainDN = "DC=galactic,DC=empire,DC=local"
$GPOName = "Password Policy"
$BackupGPO = Join-Path $BackupFolder "GPO_PasswordPolicy.xml"

# Restore GPO from backup
Try {
    Import-GPO -BackupGpoName $GPOName -Path $BackupFolder -TargetName $GPOName -CreateIfNeeded -ErrorAction Stop
    Write-Host "Restored GPO: $GPOName from backup." -ForegroundColor Green
} Catch {
    Write-Warning "Failed to restore GPO: $GPOName. Error: $_"
    Exit 1
}

# Link restored GPO to the domain root
Try {
    New-GPLink -Name $GPOName -Target $DomainDN
    Write-Host "Linked GPO '$GPOName' to domain root." -ForegroundColor Cyan
} Catch {
    Write-Warning "Failed to link GPO: $GPOName. Error: $_"
}
