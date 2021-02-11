$DriverPath = Get-Item "d:\virtio-win-0.1.173\*\2k12r2\amd64" 

$CertStore = Get-Item "cert:\LocalMachine\TrustedPublisher" 
$CertStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

Get-ChildItem -Recurse -Path $DriverPath -Filter "*.cat" | % {
    $Cert = (Get-AuthenticodeSignature $_.FullName).SignerCertificate

    Write-Host ( "Added {0}, {1} from {2}" -f $Cert.Thumbprint,$Cert.Subject,$_.FullName )

    $CertStore.Add($Cert)
}
