# Win 11 specific debloat options
# Based on: https://github.com/Raphire/Win11Debloat/blob/master/Win11Debloat.ps1

# App Removal List
# The apps below this line WILL be uninstalled. If you wish to KEEP any of the apps below
#  simply add a # character in front of the specific app in the list below.
#
appslist = @(
    "Clipchamp.Clipchamp"
    "Microsoft.3DBuilder"
    "Microsoft.549981C3F5F10"   #Cortana app
    "Microsoft.BingFinance"
    "Microsoft.BingFoodAndDrink"            
    "Microsoft.BingHealthAndFitness"         
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingTravel" 
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"   # Cannot be uninstalled in Windows 11
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftJournal"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality".Portal
    "Microsoft.NetworkSpeedTest"
    "Microsoft.News"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Todos"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.XboxApp"   # Old Xbox Console Companion App, no longer supported
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.MicrosoftFamily"   # Family Safety App
    "MicrosoftCorporationII.QuickAssist"
    "MicrosoftTeams" # Old MS Teams personal (MS Store)
    "MSTeams" # #New MS Teams app

    "ACGMediaPlayer"
    "ActiproSoftwareLLC"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "Amazon.com.Amazon"
    "AmazonVideo.PrimeVideo"
    "Asphalt8Airborne "
    "AutodeskSketchBook"
    "CaesarsSlotsFreeCasino"
    "COOKINGFEVER"
    "CyberLinkMediaSuiteEssentials"
    "DisneyMagicKingdoms"
    "Disney"
    "DrawboardPDF"
    "Duolingo-LearnLanguagesforFree"
    "EclipseManager"
    "Facebook"
    "FarmVille2CountryEscape"
    "fitbit"
    "Flipboard"
    "HiddenCity"
    "HULULLC.HULUPLUS"
    "iHeartRadio"
    "Instagram"
    "king.com.BubbleWitch3Saga"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "LinkedInforWindows"
    "MarchofEmpires"
    "Netflix"
    "NYTCrossword"
    "OneCalendar"
    "PandoraMediaInc"
    "PhototasticCollage"
    "PicsArt-PhotoStudio"
    "Plex"
    "PolarrPhotoEditorAcademicEdition"
    "Royal Revolt"
    "Shazam"
    "Sidia.LiveWallpaper"
    "SlingTV"
    "Spotify"
    "TikTok"
    "TuneInRadio"
    "Twitter"
    "Viber"
    "WinZipUniversal"
    "Wunderlist"
    "XING"

    # The apps below this line will NOT be uninstalled. If you wish to REMOVE any of the apps below 
    #  simply remove the # character in front of the specific app.
    #
    "Microsoft.Edge"                         # Edge browser (Can only be uninstalled in European Economic Area)
    #Microsoft.GetHelp                      # Required for some Windows 11 Troubleshooters
    #Microsoft.MSPaint                      # Paint 3D
    "Microsoft.OneDrive"                     # OneDrive consumer
    #Microsoft.Paint                        # Classic Paint
    #Microsoft.ScreenSketch                 # Snipping Tool
    #Microsoft.Whiteboard                   # Only preinstalled on devices with touchscreen and/or pen support
    #Microsoft.Windows.Photos
    #Microsoft.WindowsCalculator
    #Microsoft.WindowsCamera
    #Microsoft.WindowsStore                 # Microsoft Store, WARNING: This app cannot be reinstalled!
    #Microsoft.WindowsTerminal              # New default terminal app in windows 11
    #Microsoft.Xbox.TCUI                    # UI framework, seems to be required for MS store, photos and certain games
    "Microsoft.XboxIdentityProvider"         # Xbox sign-in framework, required for some games
    "Microsoft.XboxSpeechToTextOverlay"      # Might be required for some games, WARNING: This app cannot be reinstalled!
    "Microsoft.YourPhone"                    # Phone link
    "Microsoft.ZuneMusic"                    # Modern Media Player

    # The apps below will NOT be uninstalled unless selected during the custom setup selection or when
    #  launching the script with the specific parameters found in the README.md file. 
    #
    "Microsoft.GamingApp"                    # Modern Xbox Gaming App, required for installing some PC games
    "Microsoft.OutlookForWindows"            # New mail app: Outlook for Windows
    "Microsoft.People"                       # Required for & included with Mail & Calendar
    "Microsoft.PowerAutomateDesktop"
    #Microsoft.RemoteDesktop
    "Microsoft.windowscommunicationsapps"    # Mail & Calendar
    "Microsoft.XboxGameOverlay"              # Game overlay, required/useful for some games
    "Microsoft.XboxGamingOverlay"            # Game overlay, required/useful for some games
    "Windows.DevHome"

    "Microsoft.BingSearch"
)

function ForceRemoveEdge {
    # Based on work from loadstring1 & ave9858
    Write-Output "> Forcefully uninstalling Microsoft Edge..."

    $regView = [Microsoft.Win32.RegistryView]::Registry32
    $hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regView)
    $hklm.CreateSubKey('SOFTWARE\Microsoft\EdgeUpdateDev').SetValue('AllowUninstall', '')

    # Create stub (Creating this somehow allows uninstalling edge)
    $edgeStub = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
    New-Item $edgeStub -ItemType Directory | Out-Null
    New-Item "$edgeStub\MicrosoftEdge.exe" | Out-Null

    # Remove edge
    $uninstallRegKey = $hklm.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge')
    if($uninstallRegKey -ne $null) {
        Write-Output "Running uninstaller..."
        $uninstallString = $uninstallRegKey.GetValue('UninstallString') + ' --force-uninstall'
        Start-Process cmd.exe "/c $uninstallString" -WindowStyle Hidden -Wait

        Write-Output "Removing leftover files..."

        $appdata = $([Environment]::GetFolderPath('ApplicationData'))

        $edgePaths = @(
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
            "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk",
            "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk",
            "$env:PUBLIC\Desktop\Microsoft Edge.lnk",
            "$env:USERPROFILE\Desktop\Microsoft Edge.lnk",
            "$appdata\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Tombstones\Microsoft Edge.lnk",
            "$appdata\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk",
            "$edgeStub"
        )

        foreach ($path in $edgePaths){
            if (Test-Path -Path $path) {
                Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "  Removed $path" -ForegroundColor DarkGray
            }
        }

        Write-Output "Cleaning up registry..."

        # Remove ms edge from autostart
        reg delete "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" /v "MicrosoftEdgeAutoLaunch_A9F6DCE4ABADF4F51CF45CD7129E3C6C" /f *>$null
        reg delete "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" /v "Microsoft Edge Update" /f *>$null
        reg delete "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "MicrosoftEdgeAutoLaunch_A9F6DCE4ABADF4F51CF45CD7129E3C6C" /f *>$null
        reg delete "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Microsoft Edge Update" /f *>$null

        Write-Output "Microsoft Edge was uninstalled"
    }
    else {
        Write-Output ""
        Write-Host "Error: Unable to forcefully uninstall Microsoft Edge, uninstaller could not be found" -ForegroundColor Red
    }
    
    Write-Output ""
}

# Removes apps specified during function call from all user accounts and from the OS image.
function RemoveApps {
    param (
        $appslist
    )

    Foreach ($app in $appsList) { 
        Write-Output "Attempting to remove $app..."

        if (($app -eq "Microsoft.OneDrive") -or ($app -eq "Microsoft.Edge")) {
            # Use winget to remove OneDrive and Edge
            if ($global:wingetInstalled -eq $false) {
                Write-Host "WinGet is either not installed or is outdated, so $app could not be removed" -ForegroundColor Red
            }
            else {
                # Uninstall app via winget
                Strip-Progress -ScriptBlock { winget uninstall --accept-source-agreements --disable-interactivity --id $app } | Tee-Object -Variable wingetOutput 

                If (($app -eq "Microsoft.Edge") -and (Select-String -InputObject $wingetOutput -Pattern "93")) {
                    Write-Host "Error: Unable to uninstall Microsoft Edge via Winget" -ForegroundColor Red
                    Write-Output ""

                    if ($( Read-Host -Prompt "Would you like to forcefully uninstall Edge? NOT RECOMMENDED! (y/n)" ) -eq 'y') {
                        Write-Output ""
                        ForceRemoveEdge
                    }
                }
            }
        }
        else {
            # Use Remove-AppxPackage to remove all other apps
            $app = '*' + $app + '*'

            # Remove installed app for all existing users
            if ($WinVersion -ge 22000){
                # Windows 11 build 22000 or later
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
            }
            else {
                # Windows 10
                Get-AppxPackage -Name $app -PackageTypeFilter Main, Bundle, Resource -AllUsers | Remove-AppxPackage -AllUsers
            }

            # Remove provisioned app from OS image, so the app won't be installed for any new users
            Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
        }
    }
}

# Clear all pinned apps from the start menu. 
# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
# Credit: https://github.com/Raphire/Win11Debloat/blob/master/Win11Debloat.ps1
function ClearStartMenu {
    param (
        $message,
        $applyToAllUsers = $True
    )

    Write-Output $message

    # Path to start menu template
    $startmenuTemplate = "C:\Drivers\scripts\start2.bin"

    # Check if template bin file exists, return early if it doesn't
    if (-not (Test-Path $startmenuTemplate)) {
        Write-Host "Error: Unable to clear start menu, start2.bin file missing from script folder" -ForegroundColor Red
        Write-Output ""
        return
    }

    if ($applyToAllUsers) {
        # Remove startmenu pinned apps for all users
        # Get all user profile folders
        $usersStartMenu = get-childitem -path "C:\Users\*\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

        # Copy Start menu to all users folders
        ForEach ($startmenu in $usersStartMenu) {
            $startmenuBinFile = $startmenu.Fullname + "\start2.bin"
            $backupBinFile = $startmenuBinFile + ".bak"

            # Check if bin file exists
            if (Test-Path $startmenuBinFile) {
                # Backup current startmenu file
                Move-Item -Path $startmenuBinFile -Destination $backupBinFile -Force

                # Copy template file
                Copy-Item -Path $startmenuTemplate -Destination $startmenu -Force

                Write-Output "Replaced start menu for user $($startmenu.Fullname.Split("\")[2])"
            }
            else {
                # Bin file doesn't exist, indicating the user is not running the correct version of Windows. Exit function
                Write-Host "Error: Unable to clear start menu, start2.bin file could not found for user" $startmenu.Fullname.Split("\")[2]  -ForegroundColor Red
                Write-Output ""
                return
            }
        }

        # Also apply start menu template to the default profile

        # Path to default profile
        $defaultProfile = "C:\Users\default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

        # Create folder if it doesn't exist
        if (-not(Test-Path $defaultProfile)) {
            new-item $defaultProfile -ItemType Directory -Force | Out-Null
            Write-Output "Created LocalState folder for default user"
        }

        # Copy template to default profile
        Copy-Item -Path $startmenuTemplate -Destination $defaultProfile -Force
        Write-Output "Copied start menu template to default user folder"
        Write-Output ""
    }
    else {
        # Only remove startmenu pinned apps for current logged in user
        $startmenuBinFile = "C:\Users\$([Environment]::UserName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
        $backupBinFile = $startmenuBinFile + ".bak"

        # Check if bin file exists
        if (Test-Path $startmenuBinFile) {
            # Backup current startmenu file
            Move-Item -Path $startmenuBinFile -Destination $backupBinFile -Force

            # Copy template file
            Copy-Item -Path $startmenuTemplate -Destination $startmenuBinFile -Force

            Write-Output "Replaced start menu for user $([Environment]::UserName)"
            Write-Output ""
        }
        else {
            # Bin file doesn't exist, indicating the user is not running the correct version of Windows. Exit function
            Write-Host "Error: Unable to clear start menu, start2.bin file could not found for user $([Environment]::UserName)" -ForegroundColor Red
            Write-Output ""
            return
        }
    }
}

# Disable Bing in Search
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" `
    -Name "DisableSearchBoxSuggestions" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# Disable Cortana in Search
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name "AllowCortana" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name "CortanaConsent" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# Disable AI Recall
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" `
    -Name "DisableAIDataAnalysis" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsAI" `
    -Name "DisableAIDataAnalysis" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

# Disable Chat Taskbar
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TaskbarMn" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "HideSCAMeetNow" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force

# Disable Copilot
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowCopilotButton" `
    -PropertyType DWORD `
    -Value 0x00000000 `
    -Force
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" `
    -Name "TurnOffWindowsCopilot" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsCopilot" `
    -Name "TurnOffWindowsCopilot" `
    -PropertyType DWORD `
    -Value 0x00000001 `
    -Force

###################
# Disable Telemetry
###################

# Let Apps use Advertising ID for Relevant Ads in Windows 10
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -Name "Enabled" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Tailored experiences with diagnostic data for Current User
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "TailoredExperiencesWithDiagnosticDataEnabled" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Online Speech Recognition
New-ItemProperty -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" `
    -Name "HasAccepted" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Improve Inking & Typing Recognition
New-ItemProperty -Path "HKCU:\Software\Microsoft\Input\TIPC" `
    -Name "Enabled"
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Inking & Typing Personalization
New-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" `
    -Name "RestrictImplicitInkCollection" `
    -PropertyType DWORD `
    -Value 00000001 `
    -Force
    New-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" `
    -Name "RestrictImplicitTextCollection" `
    -PropertyType DWORD `
    -Value 00000001 `
    -Force

New-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" `
    -Name "HarvestContacts" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

New-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" `
    -Name "AcceptedPrivacyPolicy" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Send only Required Diagnostic and Usage Data
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
    -Name "AllowTelemetry" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable Let Windows improve Start and search results by tracking app launches
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Start_TrackProgs" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable Activity History
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "PublishUserActivities" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Set Feedback Frequency to Never
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
    -Name "NumberOfSIUFInPeriod" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
    -Name "PeriodInNanoSeconds" `
    -Force

## Windows Suggestions
# Disable Show recommendations for tips, shortcuts, new apps, and more in start
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Start_IrisRecommendations" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable Show me notifications in the Settings app
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications" `
    -Name "EnableAccountNotifications" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Suggest ways I can finish setting up my device to get the most out of Windows
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" `
    -Name "ScoobeSystemSettingEnabled" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Sync provider ads
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowSyncProviderNotifications" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Automatic Installation of Suggested Apps
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SilentInstalledAppsEnabled" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable "Suggested" app notifications (Ads for MS services)
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" `
    -Name "Enabled" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable Show me suggestions for using my mobile device with Windows (Phone Link suggestions)
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Mobility" `
    -Name "OptedIn" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable Show account-related notifications
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Start_AccountNotifications" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

## Hide the OneDrive Folder
# note: I didn't find either of these to work
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" `
    -Name "System.IsPinnedToNameSpaceTree" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" `
    -Name "System.IsPinnedToNameSpaceTree" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# So we also needed to get rid of this one...
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" `
    -Force

## Hide the Libraries Folder
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" `
    -Force

## Align the Taskbar Left
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TaskbarAl" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Hide the Taskbar Search Box
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -Name "SearchboxTaskbarMode" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Hide the Gallery from Explorer
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" `
    -Force

# Hide Home from Explorer
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "HubMode" `
    -PropertyType DWORD `
    -Value 00000001 `
    -Force

Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" `
    -Force

## Disable Widgets on Taskbar
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TaskbarDa" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Disable widgets service
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" `
    -Name "value" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
    -Name "AllowNewsAndInterests" `
    -PropertyType DWORD `
    -Value 00000000 `
    -Force

# Don't pin the Windows Store to the Taskbar
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" `
    -Name "NoPinningStoreToTaskbar" `
    -PropertyType DWORD `
    -Value 00000001 `
    -Force

# Do the work
ClearStartMenu
RemoveApps
ForceRemoveEdge