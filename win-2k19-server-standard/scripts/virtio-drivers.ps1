# Install virtio drivers and suppress prompts to trust

# This block adds trust to all the certificates in the drivers dir.
$DriverPath = Get-Item "C:\Drivers\*" 

$CertStore = Get-Item "cert:\LocalMachine\TrustedPublisher" 
$CertStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
Get-ChildItem -Recurse -Path $DriverPath -Filter "*.cat" | % {
    $Cert = (Get-AuthenticodeSignature $_.FullName).SignerCertificate
    Write-Host ( "Added {0}, {1} from {2}" -f $Cert.Thumbprint,$Cert.Subject,$_.FullName )
    $CertStore.Add($Cert)
}

# Now we can run the installer in quiet mode.
Invoke-Expression "C:\Drivers\virtio-win-guest-tools.exe /passive /quiet"
