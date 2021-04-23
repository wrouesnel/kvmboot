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
pushd "$env:SystemRoot\SysWOW64"
.\OneDriveSetup.exe /uninstall
popd

# Remove Edge
pushd "`"${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer`""
.\setup.exe -uninstall -system-level -verbose-logging -force-uninstall
popd