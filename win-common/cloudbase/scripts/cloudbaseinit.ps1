# Script to install cloudbase-init and copy customized configuration files.
Write-Verbose "Installing Cloudbase-Init"

$arguments = @(
    "/i"
    "C:\Drivers\CloudbaseInitSetup_Stable_x64.msi"
    "/passive"
)

Start-Process msiexec.exe -Wait -ArgumentList $arguments

# Copy files from C:\Drivers\cloudbaseinit-conf
Copy-Item "C:\Drivers\cloudbase-init\cloudbase-init.conf" `
    -Destination "$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"

Copy-Item "C:\Drivers\cloudbase-init\cloudbase-init-unattend.conf" `
    -Destination "$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"

Copy-Item "C:\Drivers\cloudbase-init\Unattend.xml" `
    -Destination "$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"

# Copy the override for SSH key provisioning for Administrators
Copy-Item "C:\Drivers\cloudbase-init\sshpublickeyswin19k.py" `
    -Destination "$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\Python\Lib\site-packages\cloudbaseinit\plugins\common"

# Copy ConfigDrive override
Copy-Item "C:\Drivers\cloudbase-init\modifiedconfigdrive.py" `
    -Destination "$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\Python\Lib\site-packages\cloudbaseinit\metadata\services"

# Copy LocalScripts
Copy-Item "C:\Drivers\cloudbase-init\LocalScripts\*" `
    -Destination "$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\LocalScripts\"


# Execute the sysprep action and shutdown.
# Note: I have no idea why sysprep won't run when we use Start-Process like you'd expect to.
# So here we are doing Invoke-Expression, and not touching this very long line which works.
Write-Verbose "Sysprep and shutdown"
Invoke-Expression "C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:""$env:PROGRAMFILES\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"""