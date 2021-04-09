# This script reads a fragment written by a custom Cloudbase-Init module.
# This fragment is an autologin fragment so we execute at least 1 login as the
# administrative user in the OOBE context, which in turn allows us to forcibly
# set the computer host name.

# All this is necessary because there's no way in Windows 10 to prevent OOBE
# from resetting the hostname.

$unattend = [xml](Get-Content "C:\Windows\Panther\unattend.xml")

$oobe = $unattend.unattend.settings | Where-Object { $_.pass -eq "oobeSystem" }

$shellSetup = $oobe.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }

$fragTxt = Get-Content "C:\Windows\Panther\autologin.xml"
$nsTxt = "<dummy xmlns=`"$($unattend.unattend.NamespaceURI.ToString())`">$fragTxt</dummy>"
$fragXml = $shellSetup.OwnerDocument.ImportNode(([xml]$nsTxt).dummy.AutoLogon, $true)

$shellSetup.AppendChild($fragXml)

$unattend.Save("C:\Windows\Panther\unattend.xml")

Remove-Item -Path "C:\Windows\Panther\autologin.xml" -Force