# Enable WinRM rules
Invoke-Expression 'winrm quickconfig -quiet'

# Enable basic auth
Invoke-Expression 'winrm set winrm/config/client/auth @{Basic="true"}'

# Generate a host specific self-signed certificate
$hostname = $(Invoke-Expression -Command 'hostname')

# Set expiry date 99 years into the future. This certificate is private and
# never shared - there is no sensible revocation horizon.
$expiry_date = (Get-Date).AddMonths(1188)

# Generate and get thumbprint
$thumbprint = (New-SelfSignedCertificate -DnsName $hostname -NotAfter $expiry_date -Cert Cert:\LocalMachine\My).Thumbprint

# Initialize WinRM
Invoke-Expression 'winrm create winrm/config/listener?Address=*+Transport=HTTPS `@`{Hostname=`"$hostname`"`; CertificateThumbprint=`"$thumbprint`"`}'

# Create Firewall Rule
New-NetFirewallRule `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Group "Windows Remote Management" `
    -Direction Inbound `
    -LocalPort 5986 `
    -Protocol TCP `
    -Action Allow
