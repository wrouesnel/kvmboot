# Configure global system settings useful for virtual machines

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "disablecad" `
    -Value 1