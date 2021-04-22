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
