# This script can be run at LocalScript time to setup automatic
# console login.

$metadata = Get-Content -Path "D:\openstack\latest\meta_data.json" | Out-String | ConvertFrom-Json

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "AutoAdminLogon" `
    -PropertyType String `
    -Value "1" `
    -Force

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "DefaultDomainName" `
    -PropertyType String `
    -Value "" `
    -Force

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "DefaultUserName" `
    -PropertyType String `
    -Value $metadata.meta.admin_username `
    -Force

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "DefaultPassword" `
    -PropertyType String `
    -Value $metadata.meta.admin_password `
    -Force
