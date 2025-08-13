# windows-server-admin-lab

A comprehensive lab environment designed to showcase my Windows Server system administration skills, best practices, and automation techniques. This repository demonstrates:

- Automated deployment and configuration of Active Directory
- Organizational Unit (OU) design and management
- Bulk user creation and management
- Group Policy Object (GPO) configuration for security and customization
- Installation and configuration of essential server roles (AD DS, DNS, File Services)
- Security hardening, backup, and recovery strategies
- Remote management and hybrid cloud integration

## Purpose
This project is a personal portfolio to demonstrate my practical Windows Server administration skills to potential employers. All scripts, configurations, and documentation are created and maintained by me.

## Windows Server 2025 Lab Image
- [Download Evaluation ISO](https://go.microsoft.com/fwlink/?linkid=2293312&clcid=0x409&culture=en-us&country=us)
- Version: 26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso

### ServerRoles.ps1 cannot be loaded. The file ServerRoles.ps1 is not digitally signed. You cannot run this script on the current system. For more information about running scripts and setting execution policy, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.
- run ```Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass``` in PowerShell before executing the script.

---
Created and maintained by Ludvig Almvaang.
