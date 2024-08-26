#  Description:
# This script removes unwanted Apps that come with Windows. If you do not want
# to remove certain Apps comment out the corresponding lines below.

Write-Verbose "Uninstalling default apps"
$apps = @(
    "2FE3CB00.PicsArt-PhotoStudio"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "7EE7776C.LinkedInforWindows"
    "9E2F88E3.Twitter"
    "C27EB4BA.DropboxOEM"
    "ClearChannelRadioDigital.iHeartRadio"
    "D52A8D61.FarmVille2CountryEscape"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Drawboard.DrawboardPDF"
    "Flipboard.Flipboard"
    "GAMELOFTSA.Asphalt8Airborne"
    "king.com.*"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "Microsoft.3DBuilder"
    "Microsoft.Advertising.Xaml"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTravel"
    "Microsoft.BingWeather"
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.DesktopAppInstaller"
    "Microsoft.FreshPaint"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MinecraftUWP"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Netflix"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.Desktop"
    "Microsoft.OfficeLens"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.OneDrive"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "Microsoft.Windows.CloudExperienceHost"
    "microsoft.windowscommunicationsapps"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.Windows.NarratorQuickStart"
    "Microsoft.Windows.PeopleExperienceHost"
    "Microsoft.WindowsPhone"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsReadingList"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxLive"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.Xbox.TCUI"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "PandoraMediaInc.29680B314EFC2"
    "ShazamEntertainmentLtd.Shazam"
    "TheNewYorkTimes.NYTCrossword"
    "TuneIn.TuneInRadio"
    "Windows.CBSPreview"
    "SpotifyAB.SpotifyMusic"
)

foreach ($app in $apps) {
    echo "Trying to remove $app"
    try {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
        Get-AppXProvisionedPackage -Online |
            where DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online
    } catch {
        echo "Cannot remove $app - continuing"
    }
}

# Fix the Start Menu as best We can
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartPage" `
    -Name "DesktopFirst" `
    -Value 0x00000001 `
    -Force

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartPage" `
    -Name "MakeAllAppsDefault" `
    -Value 0x00000001 `
    -Force

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartPage" `
    -Name "OpenAtLogon" `
    -Value 0x00000000 `
    -Force
