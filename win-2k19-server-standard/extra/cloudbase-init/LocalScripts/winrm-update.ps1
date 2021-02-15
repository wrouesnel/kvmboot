# This is a first boot script which replaces the WinRM certificate with
# the real one.

# Generate and get thumbprint
Write-Verbose "Self-signed SSL certificate generated; thumbprint: $thumbprint"
$thumbprint = (New-SelfSignedCertificate `
    -DnsName $SubjectName `
    -NotBefore $notBefore `
    -NotAfter $expiry_date `
    -Cert Cert:\LocalMachine\My).Thumbprint

# Create the hashtables of settings to be used.
$valueset = @{
    Hostname = $SubjectName
    CertificateThumbprint = $thumbprint
}

$selectorset = @{
    Transport = "HTTPS"
    Address = "*"
}

$valueset = @{
    Hostname = $SubjectName
    CertificateThumbprint = $thumbprint
}

Set-WSManInstance -ResourceURI winrm/config/Listener `
                  -SelectorSet $selectorset `
                  -ValueSet $valueset

Restart-Service -Force -Name WinRM }

Write-Verbose "Refreshed WinRM certificate"