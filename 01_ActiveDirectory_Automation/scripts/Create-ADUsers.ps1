<#
.SYNOPSIS
    Creates Active Directory users from a CSV file.

.DESCRIPTION
    This script reads user data from a CSV file (new_users.csv) and creates
    each user in the specified Organizational Unit (OU) in Active Directory.

.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-12
#>

# Path to the CSV file
$CsvPath = "..\ExampleData\new_users.csv"

# Set your AD domain components here
$DomainDN = "DC=galactic,DC=empire,DC=local"

# Import the CSV
Try {
    $Users = Import-Csv -Path $CsvPath
    Write-Host "Successfully imported user data from CSV.`n" -ForegroundColor Green
} Catch {
    Write-Error "Failed to import CSV file. Check the path: $CsvPath"
    Exit
}

# Loop through each user and create the AD account
foreach ($User in $Users) {
    $FullName = "$($User.FirstName) $($User.LastName)"
    $OUName = $User.OU
    $OUPath = "OU=$OUName,$DomainDN"

    # Skip if any required field is missing
    if (-not $User.FirstName -or -not $User.LastName -or -not $User.Username -or -not $User.Password -or -not $User.OU) {
        Write-Warning "Missing data for user: $FullName. Skipping..."
        continue
    }

    # Create the user
    Try {
        New-ADUser `
            -Name $FullName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $User.Username `
            -UserPrincipalName "$($User.Username)@example.com" `
            -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
            -Enabled $true `
            -Path $OUPath `
            -ChangePasswordAtLogon $false `
            -PasswordNeverExpires $true

        Write-Host "Created user: $FullName in OU: $OUName" -ForegroundColor Cyan
    } Catch {
        Write-Warning "Failed to create user: $FullName. Error: $_"
    }
}
