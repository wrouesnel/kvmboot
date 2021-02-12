# Adapter from: https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1

# Find and start the WinRM service.
Write-Verbose "Verifying WinRM service."
If (!(Get-Service "WinRM"))
{
    Write-Log "Unable to find the WinRM service."
    Throw "Unable to find the WinRM service."
}
ElseIf ((Get-Service "WinRM").Status -ne "Running")
{
    Write-Verbose "Setting WinRM service to start automatically on boot."
    Set-Service -Name "WinRM" -StartupType Automatic
    Write-Log "Set WinRM service to start automatically on boot."
    Write-Verbose "Starting WinRM service."
    Start-Service -Name "WinRM" -ErrorAction Stop
    Write-Log "Started WinRM service."

}

# WinRM should be running; check that we have a PS session config.
If (!(Get-PSSessionConfiguration -Verbose:$false) -or (!(Get-ChildItem WSMan:\localhost\Listener)))
{
    Write-Verbose "Enabling PS Remoting without checking Network profile."
    Enable-PSRemoting -SkipNetworkProfileCheck -Force -ErrorAction Stop
    Write-Log "Enabled PS Remoting without checking Network profile."
}
Else
{
    Write-Verbose "PS Remoting is already enabled."
}

# Ensure LocalAccountTokenFilterPolicy is set to 1
# Specifically: this allows remote users to take actions which engage UAC.
# https://github.com/ansible/ansible/issues/42978
$token_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$token_prop_name = "LocalAccountTokenFilterPolicy"
$token_key = Get-Item -Path $token_path
$token_value = $token_key.GetValue($token_prop_name, $null)
if ($token_value -ne 1) {
    Write-Verbose "Setting LocalAccountTOkenFilterPolicy to 1"
    if ($null -ne $token_value) {
        Remove-ItemProperty -Path $token_path -Name $token_prop_name
    }
    New-ItemProperty -Path $token_path -Name $token_prop_name -Value 1 -PropertyType DWORD > $null
}

# Generate a host specific self-signed certificate
$SubjectName = $(Invoke-Expression -Command 'hostname')

# Set expiry date 99 years into the future. This certificate is private and
# never shared - there is no sensible revocation horizon.
$expiry_date = (Get-Date).AddMonths(1188)
$notBefore = (Get-Date).AddDays(-1)

# Generate and get thumbprint
$thumbprint = (New-SelfSignedCertificate `
    -DnsName $SubjectName `
    -NotBefore $notBefore `
    -NotAfter $expiry_date `
    -Cert Cert:\LocalMachine\My).Thumbprint


# Make sure there is a SSL listener.
$listeners = Get-ChildItem WSMan:\localhost\Listener
If (!($listeners | Where-Object {$_.Keys -like "TRANSPORT=HTTPS"}))
{
    # We cannot use New-SelfSignedCertificate on 2012R2 and earlier
    $thumbprint = New-LegacySelfSignedCert -SubjectName $SubjectName -ValidDays $CertValidityDays
    Write-HostLog "Self-signed SSL certificate generated; thumbprint: $thumbprint"

    # Create the hashtables of settings to be used.
    $valueset = @{
        Hostname = $SubjectName
        CertificateThumbprint = $thumbprint
    }

    $selectorset = @{
        Transport = "HTTPS"
        Address = "*"
    }

    Write-Verbose "Enabling SSL listener."
    New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset
    Write-Log "Enabled SSL listener."
}
Else
{
    Write-Verbose "SSL listener is already active."
}

Write-Verbose "Disabling HTTP listener"
Remove-WSManInstance `
    -ResourceURI 'winrm/config/Listener' `
    -SelectorSet Address="*";Transport="HTTP"
Write-Verbose "Disabled HTTP listener"

# Check for basic authentication.
$basicAuthSetting = Get-ChildItem WSMan:\localhost\Service\Auth | Where-Object {$_.Name -eq "Basic"}
If (($basicAuthSetting.Value) -eq $false)
{
    Write-Verbose "Enabling basic auth support."
    Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $true
    Write-Log "Enabled basic auth support."
}
Else
{
    Write-Verbose "Basic auth is already enabled."
}

# Initialize WinRM
Invoke-Expression 'winrm create winrm/config/listener?Address=*+Transport=HTTPS `@`{Hostname=`"$hostname`"`; CertificateThumbprint=`"$thumbprint`"`}'

$windowsRemotingFirewallGroup = "@FirewallAPI.dll,-30267"

# Create Firewall Rule
New-NetFirewallRule `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Name "WINRM-HTTPS-In-TCP" `
    -Group $windowsRemotingFirewallGroup `
    -Direction Inbound `
    -LocalPort 5986 `
    -Protocol TCP `
    -Action Allow `
    -Profile Private,Domain

New-NetFirewallRule `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Name "WINRM-HTTPS-In-TCP-PUBLIC" `
    -Group $windowsRemotingFirewallGroup `
    -Direction Inbound `
    -LocalPort 5986 `
    -Protocol TCP `
    -Action Allow `
    -Profile Public

Write-Verbose "Disabling WinRM HTTP rules"
$rules = Get-NetFirewallRule -Group $windowsRemotingFirewallGroup

foreach ($rule in $rules) {
    switch ($rule.Name) {
        {"WINRM-HTTP-In-TCP", "WINRM-HTTP-In-TCP"} {
            Write-Verbose "Disabling builtin WinRM HTTP rule: $_.DisplayName"
            Set-NetFirewallRule -Name $rule.Name -Enabled False
        }
    }
}
Write-Verbose "Disabled WinRM HTTP rules"