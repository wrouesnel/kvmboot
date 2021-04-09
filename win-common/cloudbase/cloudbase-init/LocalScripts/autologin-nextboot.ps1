# This script reads a fragment written by a custom Cloudbase-Init module.
# This fragment is an autologin fragment so we execute at least 1 login as the
# administrative user in the OOBE context, which in turn allows us to forcibly
# set the computer host name.

# All this is necessary because there's no way in Windows 10 to prevent OOBE
# from resetting the hostname. And none of the autologon paramters in unattend.xml
# work properly.
$fragXml = [xml](Get-Content "C:\Windows\Panther\autologin.xml")

$Username = $fragXml.AutoLogon.Username
$Password = $fragXml.AutoLogon.Password.Value

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$Username" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$Password" -type String
Set-ItemProperty $RegistryPath 'AutoLogonCount' -Value "1" -type String
 
Remove-Item -Path "C:\Windows\Panther\autologin.xml" -Force
