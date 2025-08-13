<#
.SYNOPSIS
    Creates required Organizational Units (OUs) in Active Directory for user import, including sub-OUs for Users and Groups.
.DESCRIPTION
    This script creates all main OUs and sub-OUs (Users, Groups) for each main OU.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-13
#>

# List of main OUs
$MainOUs = @(
    "Navy",
    "Sith",
    "Army",
    "Intel",
    "Government"
)

# Set your AD domain components here
$DomainDN = "DC=galactic,DC=empire,DC=local"

foreach ($OUName in $MainOUs) {
    $OUPath = "OU=$OUName,$DomainDN"
    Try {
        # Create main OU if it doesn't exist
        if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$OUName)" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
            Write-Host "Created OU: $OUName" -ForegroundColor Cyan
        } else {
            Write-Host "OU already exists: $OUName" -ForegroundColor Yellow
        }
        # Create sub-OUs: Users and Groups
        foreach ($SubOU in @("Users", "Groups")) {
            $SubOUPath = "OU=$SubOU,OU=$OUName,$DomainDN"
            if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$SubOU)" -SearchBase $OUPath -ErrorAction SilentlyContinue)) {
                New-ADOrganizationalUnit -Name $SubOU -Path $OUPath
                Write-Host "Created sub-OU: $SubOU in $OUName" -ForegroundColor Green
            } else {
                Write-Host "Sub-OU already exists: $SubOU in $OUName" -ForegroundColor Yellow
            }
        }
    } Catch {
        Write-Warning "Failed to create OU or sub-OU: $OUName. Error: $_"
    }
}
