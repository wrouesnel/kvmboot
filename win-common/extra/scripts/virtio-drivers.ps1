# Install virtio drivers and suppress prompts to trust

Write-Verbose "Adding trust for Red Hat virtio drivers..."
$DriverPath = Get-Item "C:\Drivers\virtio\*" 

$CertStore = Get-Item "cert:\LocalMachine\TrustedPublisher" 
$CertStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
Get-ChildItem -Recurse -Path $DriverPath -Filter "*.cat" | % {
    $Cert = (Get-AuthenticodeSignature $_.FullName).SignerCertificate
    Write-Host ( "Added {0}, {1} from {2}" -f $Cert.Thumbprint,$Cert.Subject,$_.FullName )
    $CertStore.Add($Cert)
}
Write-Verbose "Added trust for Red Hat virtio drivers."

Write-Verbose "Installing Virtio Guest Drivers..."
Start-Process "C:\Drivers\virtio\virtio-win-guest-tools.exe" `
    -ArgumentList "/passive /quiet" `
    -Wait
Write-Verbose "Installed Virtio Guest Drivers."