# Install the OpenSSH server.
$packageName = (Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Server*')[0].Name

Add-WindowsCapability -Online -Name $packageName

# Configure Powershell as the default shell.
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
    -Name DefaultShell `
    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -PropertyType String `
    -Force

# Open firewall for SSH
Start-Service sshd
# Enable on Startup
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. It should be created automatically by setup.
Get-NetFirewallRule -Name *ssh*
# There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
# If the firewall does not exist, create one
New-NetFirewallRule `
    -Name sshd `
    -DisplayName 'OpenSSH-Server-In-TCP' `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -Action Allow `
    -LocalPort 22
