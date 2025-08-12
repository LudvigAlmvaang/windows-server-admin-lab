# Active Directory Automation Lab

This lab automates the setup of Active Directory, Organizational Units, users, Group Policies, and common server roles for a Windows Server environment.

## Prerequisites
- Windows Server with administrative privileges
- PowerShell (run scripts as Administrator)
- Network share accessible for wallpaper deployment (if using Navy wallpaper GPO)
- Review all scripts before running in production

## Script Execution Order
1. **Install-ServerRoles.ps1**
   - Configures network adapter with static IP (192.168.0.25)
   - Installs AD DS and DNS roles
   - Promotes the server to a domain controller
   - Configures DNS forwarding to public DNS (1.1.1.1, 1.0.0.1)
2. **Bulk-OU-Creation.ps1**
   - Creates all required Organizational Units (OUs): Navy, Sith, Army, Intel, Government
3. **Create-ADUsers.ps1**
   - Imports users from `new_users.csv` and creates them in the correct OUs
4. **Configure-GPO.ps1**
   - Sets global password policy
   - Configures OU-specific GPOs (e.g., desktop wallpaper, disables Control Panel)
   - Deploys Navy.jpg wallpaper via logon script for Navy OU
5. **Run-All-Setup.ps1**
   - Runs all the above scripts in the correct order for full automation

## Important Considerations
- Ensure all scripts are run with sufficient privileges
- Verify domain and OU names match your environment
- For the Navy wallpaper GPO, make sure `Navy.jpg` is available on the network share and accessible by all Navy OU computers
- Test scripts in a lab environment before production use
- Review and customize script parameters as needed

## Troubleshooting
- Check PowerShell error messages for details
- Use `Get-ADUser`, `Get-ADOrganizationalUnit`, and `Get-GPO` to verify results
- Ensure network connectivity and permissions for file deployment

## Author
Ludvig Almvaang

---
For more details, see individual script comments and documentation.
