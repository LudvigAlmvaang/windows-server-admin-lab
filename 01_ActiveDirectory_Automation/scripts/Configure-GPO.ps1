<#
.SYNOPSIS
    Configures global and OU-specific Group Policy Objects (GPOs) in Active Directory.
.DESCRIPTION
    This script sets a global password policy and applies OU-specific GPOs for demonstration purposes.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-12
#>

# Set global password policy (applies to entire domain)
$GPONameGlobal = "Global Password Policy"
$DomainDN = "DC=galactic,DC=empire,DC=local"

# Create global GPO
$GPOGlobal = New-GPO -Name $GPONameGlobal -ErrorAction Stop
Write-Host "Created global GPO: $GPONameGlobal" -ForegroundColor Cyan

# Link global GPO to domain root
New-GPLink -Name $GPONameGlobal -Target $DomainDN
Write-Host "Linked global GPO '$GPONameGlobal' to domain root" -ForegroundColor Green

# Set password policy (example: minimum password length)
Set-GPRegistryValue -Name $GPONameGlobal -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordLength" -Type DWord -Value 12
Write-Host "Configured global minimum password length to 12 characters." -ForegroundColor Yellow

# OU-specific GPO example: "Navy" OU - Desktop Wallpaper
$GPONameNavyWallpaper = "Navy Desktop Wallpaper"
$OUNameNavy = "Navy"
$OUPathNavy = "OU=$OUNameNavy,$DomainDN"
$WallpaperPath = "C:\Windows\Web\Wallpaper\Navy.jpg"

$GPONavyWallpaper = New-GPO -Name $GPONameNavyWallpaper -ErrorAction Stop
Write-Host "Created OU-specific GPO: $GPONameNavyWallpaper" -ForegroundColor Cyan
New-GPLink -Name $GPONameNavyWallpaper -Target $OUPathNavy
Write-Host "Linked GPO '$GPONameNavyWallpaper' to OU '$OUNameNavy'" -ForegroundColor Green
Set-GPRegistryValue -Name $GPONameNavyWallpaper -Key "HKCU\Control Panel\Desktop" -ValueName "Wallpaper" -Type String -Value $WallpaperPath
Write-Host "Configured desktop wallpaper for Navy OU." -ForegroundColor Yellow

# OU-specific GPO: Disable Control Panel for Navy and Army OUs
$GPONameDisableCP = "Disable Control Panel"
$OUsDisableCP = @("Navy", "Army")

$GPODisableCP = New-GPO -Name $GPONameDisableCP -ErrorAction Stop
Write-Host "Created OU-specific GPO: $GPONameDisableCP" -ForegroundColor Cyan
Set-GPRegistryValue -Name $GPONameDisableCP -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
Write-Host "Configured Control Panel disable policy." -ForegroundColor Yellow

foreach ($OUName in $OUsDisableCP) {
    $OUPath = "OU=$OUName,$DomainDN"
    New-GPLink -Name $GPONameDisableCP -Target $OUPath
    Write-Host "Linked GPO '$GPONameDisableCP' to OU '$OUName'" -ForegroundColor Green
}

# OU-specific GPO: Ensure Navy.jpg wallpaper is present on Navy OU computers
$GPONameNavyWallpaperCopy = "Navy Wallpaper File Copy"
$GPONavyWallpaperCopy = New-GPO -Name $GPONameNavyWallpaperCopy -ErrorAction Stop
Write-Host "Created OU-specific GPO: $GPONameNavyWallpaperCopy" -ForegroundColor Cyan
New-GPLink -Name $GPONameNavyWallpaperCopy -Target $OUPathNavy
Write-Host "Linked GPO '$GPONameNavyWallpaperCopy' to OU '$OUNameNavy'" -ForegroundColor Green

# Note: The following configures a logon script to copy the Navy.jpg file from a network share to the local path
# Define network share and local path
$NetworkWallpaperPath = "\\server\share\Navy.jpg"
$LocalWallpaperPath = "C:\Windows\Web\Wallpaper\Navy.jpg"
$LogonScript = @"
Copy-Item -Path '$NetworkWallpaperPath' -Destination '$LocalWallpaperPath' -Force
"@

# Add logon script to the GPO
$ScriptName = "CopyNavyWallpaper.ps1"
$ScriptPath = "\\server\netlogon\$ScriptName"
Set-Content -Path $ScriptPath -Value $LogonScript
Set-GPLogonScript -Name $GPONameNavyWallpaperCopy -ScriptName $ScriptName -ScriptParameters ""
Write-Host "Configured logon script to copy Navy.jpg for Navy OU." -ForegroundColor Yellow
