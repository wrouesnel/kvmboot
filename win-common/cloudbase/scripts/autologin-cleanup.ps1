# Ensure the autologin parameters are deleted from the registry after the final
# OOBE section.

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

Remove-ItemProperty -Path $RegistryPath -Name 'AutoAdminLogon' -Force
Remove-ItemProperty -Path $RegistryPath -Name 'DefaultUserName' -Force
Remove-ItemProperty -Path $RegistryPath -Name 'DefaultPassword' -Force
Remove-ItemProperty -Path $RegistryPath -Name 'AutoLogonCount' -Force

Remove-ItemProperty -Path $RegistryPath -Name 'ForceAutoLogon' -Force

Remove-ItemProperty -Path $RegistryPath -Name 'LastUsedUsername' -Force
Remove-ItemProperty -Path $RegistryPath -Name 'AutoLogonSID' -Force
Remove-Item -Path "$RegistryPath\AutoLogonChecked" -Force

