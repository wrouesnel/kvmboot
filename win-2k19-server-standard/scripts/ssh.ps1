# Install the OpenSSH server.
$packageName = (Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Server*')[0].Name

Add-WindowsCapability -Online -Name $packageName

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
