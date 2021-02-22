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
    -Name "SearchboxTaskbar" `
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
    -Recurse
    -Force