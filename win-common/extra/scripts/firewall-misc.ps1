
# Allow ICMPv4 ping requests (ECHO)
New-NetFirewallRule `
    -DisplayName "Allow ICMPv4 Ping" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -Action Allow

# Note: in theory this should be done in the Unattend.xml file. In practice,
# once Win 10 gets involved, it seems almost impossible to make that file work
# reliably. So we do our firewall provisioning for Remote Desktop here.

# Disable Network Discovery
Write-Verbose "Disabling Network Discovery Rules"
foreach ($rule in Get-NetFirewallRule -DisplayGroup "Network Discovery") {
    Set-NetFirewallRule -Name $rule.Name -Enabled False
}

# Enable Remote Desktop
Write-Verbose "Enabling Remote Desktop Rules"
foreach ($rule in Get-NetFirewallRule -DisplayGroup "Remote Desktop") {
    Set-NetFirewallRule -Name $rule.Name -Enabled True
}