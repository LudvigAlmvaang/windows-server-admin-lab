<#
.SYNOPSIS
    Creates required Organizational Units (OUs) in Active Directory for user import.
.DESCRIPTION
    This script creates all OUs needed for the user accounts listed in new_users.csv.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-12
#>

# List of required OUs
$OUs = @(
    "Navy",
    "Sith",
    "Army",
    "Intel",
    "Government"
)

# Set your AD domain components here
$DomainDN = "DC=galactic,DC=empire,DC=local"

foreach ($OUName in $OUs) {
    $OUPath = "OU=$OUName,$DomainDN"
    Try {
        # Check if OU already exists
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
            Write-Host "Created OU: $OUName" -ForegroundColor Cyan
        } else {
            Write-Host "OU already exists: $OUName" -ForegroundColor Yellow
        }
    } Catch {
        Write-Warning "Failed to create OU: $OUName. Error: $_"
    }
}
