<#
.SYNOPSIS
    Installs common Windows Server roles and features.
.DESCRIPTION
    This script installs selected server roles such as AD DS, DNS, and File Services for lab setup.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-12
#>

# List of roles to install
$Roles = @(
    "AD-Domain-Services",
    "DNS",
    "File-Services"
)

foreach ($Role in $Roles) {
    Try {
        Install-WindowsFeature -Name $Role -IncludeManagementTools -ErrorAction Stop
        Write-Host "Installed role: $Role" -ForegroundColor Green
    } Catch {
        Write-Warning "Failed to install role: $Role. Error: $_"
    }
}

# Optional: Promote server to domain controller if AD DS was installed
if ($Roles -contains "AD-Domain-Services") {
    Write-Host "Promoting server to domain controller..." -ForegroundColor Cyan
    # Example: Install-ADDSForest -DomainName "galactic.empire.local" -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force)
    # Uncomment and customize the above line as needed
}
