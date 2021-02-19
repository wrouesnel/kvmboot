
# Allow ICMPv4 ping requests (ECHO)
New-NetFirewallRule `
    -DisplayName "Allow ICMPv4 Ping" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -Action Allow
