# Set up Windows Update for Powershell and do an Initial Update

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-Module PSWindowsUpdate

Add-WUServiceManager -MicrosoftUpdate -Confirm:$false

# Install Updates
Get-WUInstall -AcceptAll -IgnoreReboot

Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName "NetFx3"