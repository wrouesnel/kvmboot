# Sets some UX annoyances in Windows

# *************************************************************
# * Change how often Windows asks you for feedback to "NEVER" *
# *************************************************************

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
    -Name "NumberOfSIUFInPeriod" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
    -Name "PeriodInNanoSeconds" `
    -Force

# **********************************
# * Disable feedback notifications *
# **********************************

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name "DoNotShowFeedbackNotifications" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# ******************************************************************
# * Disable "Get tips, tricks, and suggestions as you use Windows" *
# ******************************************************************

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338389Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ******************************************
# * Disable the Windows welcome experience *
# ******************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-310093Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ************************************
# * Disable app suggestions in start *
# ************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338388Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ****************************************************
# * Disable display of suggested content in settings *
# ****************************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338393Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-353694Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-353696Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ******************************************************
# * Turn off tailored experiences with diagnostic data *
# ******************************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "TailoredExperiencesWithDiagnosticDataEnabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ************************************
# * Turn off suggestions in timeline *
# ************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-353698Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# *****************************************
# * Disable Tips, Tricks, and Suggestions *
# *****************************************

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338389Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# *****************************************
# * Suggest ways to finish setting up *
# *****************************************

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" `
    -Name "ScoobeSystemSettingEnabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ****************************************
# * Display seconds on the taskbar clock *
# ****************************************

# This will cause the clock on the taskbar to show seconds. Windows Explorer needs to be restarted
# before this will take effect.

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowSecondsInSystemClock" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

#       ********************************
#       * File Explorer Customizations *
#       ********************************

# ************************************
# * Turn on Expand to current folder *
# * Turn on Show all folders         *
# ************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "NavPaneExpandToCurrentFolder" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "NavPaneShowAllFolders" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# **************************
# * Turn on Show Libraries *
# **************************

New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" `
    -Name "System.IsPinnedToNameSpaceTree" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# **************************************
# * Display full path in the title bar *
# **************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" `
    -Name "FullPath" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# *********************
# * Show empty drives *
# *********************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideDrivesWithNoMedia" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideDrivesWithNoMedia" `
    -Force

# *****************************
# * Show file name extensions *
# *****************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideFileExt" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ************************************************
# * Show encrypted and compressed files in color *
# ************************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowEncryptCompressedColor" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# ****************************************
# * Show hidden files folders and drives *
# ****************************************

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Hidden" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# *****************************************
# * Hide protected operating system files *
# *****************************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowSuperHidden" `
    -PropertyType DWORD `
    -Value 1 `
    -Force

# ***********************************
# * Use check boxes to select items *
# ***********************************

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "AutoCheckSelect" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# ******************************
# * Disable the sharing wizard *
# ******************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "SharingWizardOn" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# ***********************************
# * Launch File Explorer to This PC *
# ***********************************

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "LaunchTo" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# *********************************** *
# * Launch Control Panel to Icon View *
# *********************************** *
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "ForceClassicControlPanel" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# *********************************** *
# * Turn off the search bar           *
# *********************************** *
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "SearchboxTaskbarMode" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# *********************************** *
# * Turn off task view button         *
# *********************************** *
New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MultitaskingView" `
    -Force

New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MultitaskingView\AllUpView" `
    -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MultitaskingView\AllUpView" `
    -Name "Enabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowTaskViewButton" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# *********************************** *
# * Hide the Cortana button           *
# *********************************** *
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "CortanaEnabled" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# *********************************** *
# * Remove default pinned tasks       *
# *********************************** *
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" `
    -Recurse `
    -Force

New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" `
    -Force

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" `
    -Name "Favorites" `
    -PropertyType BINARY `
    -Value ([byte[]](0x00,0xa8,0x01,0x00,0x00,0x3a,0x00,0x1f,0x80,0xc8,0x27,0x34,0x1f,0x10,0x5c,0x10,0x42,0xaa,0x03,0x2e,0xe4, `
        0x52,0x87,0xd6,0x68,0x26,0x00,0x01,0x00,0x26,0x00,0xef,0xbe,0x12,0x00,0x00,0x00,0x50,0x89,0xee,0x7a,0xf0,0x37,0xd7,0x01,0x90, `
        0x2b,0x64,0xe7,0xef,0x37,0xd7,0x01,0xb1,0xf7,0xbd,0xf4,0xf3,0x37,0xd7,0x01,0x14,0x00,0x56,0x00,0x31,0x00,0x00,0x00,0x00,0x00, `
        0x97,0x52,0x72,0x1e,0x11,0x00,0x54,0x61,0x73,0x6b,0x42,0x61,0x72,0x00,0x40,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x97,0x52,0x56, `
        0x1b,0x97,0x52,0x72,0x1e,0x2e,0x00,0x00,0x00,0xbd,0x97,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, `
        0x00,0x00,0x00,0x00,0x00,0x00,0x4f,0xdc,0x64,0x00,0x54,0x00,0x61,0x00,0x73,0x00,0x6b,0x00,0x42,0x00,0x61,0x00,0x72,0x00,0x00, `
        0x00,0x16,0x00,0x16,0x01,0x32,0x00,0x97,0x01,0x00,0x00,0x87,0x4f,0x07,0x49,0x20,0x00,0x46,0x49,0x4c,0x45,0x45,0x58,0x7e,0x32, `
        0x2e,0x4c,0x4e,0x4b,0x00,0x00,0x84,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x97,0x52,0x72,0x1e,0x97,0x52,0x72,0x1e,0x2e,0x00,0x00, `
        0x00,0x89,0xa1,0x01,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x00,0x00,0x58,0x9c, `
        0x44,0x00,0x46,0x00,0x69,0x00,0x6c,0x00,0x65,0x00,0x20,0x00,0x45,0x00,0x78,0x00,0x70,0x00,0x6c,0x00,0x6f,0x00,0x72,0x00,0x65, `
        0x00,0x72,0x00,0x20,0x00,0x28,0x00,0x32,0x00,0x29,0x00,0x2e,0x00,0x6c,0x00,0x6e,0x00,0x6b,0x00,0x00,0x00,0x40,0x00,0x73,0x00, `
        0x68,0x00,0x65,0x00,0x6c,0x00,0x6c,0x00,0x33,0x00,0x32,0x00,0x2e,0x00,0x64,0x00,0x6c,0x00,0x6c,0x00,0x2c,0x00,0x2d,0x00,0x32, `
        0x00,0x32,0x00,0x30,0x00,0x36,0x00,0x37,0x00,0x00,0x00,0x1c,0x00,0x22,0x00,0x00,0x00,0x1e,0x00,0xef,0xbe,0x02,0x00,0x55,0x00, `
        0x73,0x00,0x65,0x00,0x72,0x00,0x50,0x00,0x69,0x00,0x6e,0x00,0x6e,0x00,0x65,0x00,0x64,0x00,0x00,0x00,0x1c,0x00,0x12,0x00,0x00, `
        0x00,0x2b,0x00,0xef,0xbe,0xb1,0xf7,0xbd,0xf4,0xf3,0x37,0xd7,0x01,0x1c,0x00,0x42,0x00,0x00,0x00,0x1d,0x00,0xef,0xbe,0x02,0x00, `
        0x4d,0x00,0x69,0x00,0x63,0x00,0x72,0x00,0x6f,0x00,0x73,0x00,0x6f,0x00,0x66,0x00,0x74,0x00,0x2e,0x00,0x57,0x00,0x69,0x00,0x6e, `
        0x00,0x64,0x00,0x6f,0x00,0x77,0x00,0x73,0x00,0x2e,0x00,0x45,0x00,0x78,0x00,0x70,0x00,0x6c,0x00,0x6f,0x00,0x72,0x00,0x65,0x00, `
        0x72,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0xff)) `
    -Force

# ************************************************************************ *
# * Edge Prelaunch, Default Browser Pop and the Use Edge Popup (hopefully) *
# ************************************************************************ *

New-Item -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge" `
    -Force

New-Item -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" `
    -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" `
    -Name "DisallowDefaultBrowserPrompt" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" `
    -Name "AllowPrelaunch" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge" `
    -Force

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" `
    -Name "AllowPrelaunch" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" `
    -Name "DisallowDefaultBrowserPrompt" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableHelpSticker" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Edge" `
    -Name "HideFirstRunExperience" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "EdgeDesktopShortcutCreated" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "EdgeDesktopShortcutCreated" `
    -Value 0x00000001 `
    -Force


# *********************************** *
# * The creepy Hi animation           *
# *********************************** *
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableFirstLogonAnimation" `
    -Value 0x00000000 `
    -Force

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "EnableFirstLogonAnimation" `
    -Value 0x00000000 `
    -Force

# *********************************** *
# * Always show full systray          *
# *********************************** *
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "EnableAutoTray" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# *********************************** *
# * Disable Live Tiles                *
# *********************************** *
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" `
    -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" `
    -Name "NoTileApplicationNotification" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# ************************************************************ *
# * Disable Windows Consumer features (stop installed Spotify) *
# ************************************************************ *
# Hard to know where this one should really go.
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DisableWindowsConsumerFeatures" `
    -Name "DisableWindowsConsumerFeatures" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# *********************************** *
# * Disable Silent App Installs                *
# *********************************** *

foreach ($key in @(
    "ContentDeliveryAllowed"
    "OemPreInstalledAppsEnabled"
    "PreInstalledAppsEnabled"
    "PreInstalledAppsEverEnabled"
    "SilentInstalledAppsEnabled"
    "SoftLandingEnabled"
    "SubscribedContentEnabled"
)) {
    Set-ItemProperty `
        -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name $key `
        -Value 0x00000000 `
        -Force
}

Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" `
    -Recurse `
    -Force

Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps" `
    -Recurse `
    -Force

# ************************************************************ *
# * Disable web search suggestions in the Start Menu *
# ************************************************************ *
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "DisableSearchBoxSuggestions" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force