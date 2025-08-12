<#
.SYNOPSIS
    Installs AD DS, DNS, and configures network adapter with a static IP on Windows Server (Core or GUI).
.DESCRIPTION
    This script installs required roles, configures the network adapter, and promotes the server to a domain controller.
.NOTES
    Author: Ludvig Almvaang
    Date:   2025-08-12
#>

# Variables
$DomainName = "galactic.empire.local"
$SafeModePassword = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
$IPAddress = "192.168.0.25"
$SubnetMask = "255.255.255.0"
$DefaultGateway = "192.168.0.1"
$DNSServers = @("192.168.0.25")

# Get the primary network adapter
$Adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

if ($null -eq $Adapter) {
    Write-Warning "No active network adapter found."
    Exit 1
}

# Configure static IP
Try {
    New-NetIPAddress -InterfaceAlias $Adapter.Name -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway -ErrorAction Stop
    Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses $DNSServers -ErrorAction Stop
    Write-Host "Configured static IP ($IPAddress) and DNS ($($DNSServers -join ',')) on $($Adapter.Name)." -ForegroundColor Green
} Catch {
    Write-Warning "Failed to configure network adapter. Error: $_"
    Exit 1
}

# Install AD DS and DNS roles
Try {
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools -ErrorAction Stop
    Write-Host "Installed AD DS and DNS roles." -ForegroundColor Green
} Catch {
    Write-Warning "Failed to install AD DS or DNS roles. Error: $_"
    Exit 1
}

# Configure DNS forwarding for external queries
Try {
    $Forwarders = @("1.1.1.1", "1.0.0.1")
    Set-DnsServerForwarder -IPAddress $Forwarders -PassThru -ErrorAction Stop
    Write-Host "Configured DNS forwarders: $($Forwarders -join ', ')" -ForegroundColor Green
} Catch {
    Write-Warning "Failed to configure DNS forwarders. Error: $_"
}

# Promote server to domain controller and create new forest
Try {
    Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -InstallDNS -Force -NoRebootOnCompletion
    Write-Host "Domain controller promotion initiated for $DomainName." -ForegroundColor Cyan
    Write-Host "Reboot the server to complete the installation." -ForegroundColor Yellow
} Catch {
    Write-Warning "Failed to promote server to domain controller. Error: $_"
    Exit 1
}
