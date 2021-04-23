# Configure global system settings useful for virtual machines

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "disablecad" `
    -Value 1 `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableSmartScreen" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "SmartScreenEnabled" `
    -Value "Off" `
    -Force

# Set layout to something sensible
Copy-Item "C:\Drivers\scripts\StartLayout.xml" `
    -Destination "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"

Copy-Item "C:\Drivers\scripts\StartLayout.xml" `
    -Destination "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"

# Remove OneDrive
Start-Process `
    -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" `
    -ArgumentList "/uninstall" `
    -Wait

# Remove Edge
pushd "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer"
Start-Process `
    -FilePath "setup.exe" `
    -ArgumentList "-uninstall","-system-level","-verbose-logging","-force-uninstall" `
    -Wait
popd

# Delete the Edge icon
Remove-Item "$env:USERPROFILE\Desktop\*.*"
