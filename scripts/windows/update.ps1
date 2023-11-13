# CONFIG
$stcURL = "https://l.hpclab.kr/stcbuildwindows"

?## UAC
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
if (-not $myWindowsPrincipal.IsInRole($adminRole))
{
    Write-Host "Administrator privileges are required to execute this script"
    Exit;
}

# ACCELERATE DOWNLOAD
$ProgressPreference = 'SilentlyContinue'

Write-Host "Downloading Save the Choi from $stcURL"
$destinationPath = "$folderPath\stc.exe"
Invoke-WebRequest -Uri $stcURL -OutFile $destinationPath
Write-Host "Update done!"

Write-Host "Registering Save the Choi with the startup program..."
$WScriptShell = New-Object -ComObject WScript.Shell
$Startup = $WScriptShell.SpecialFolders('Startup')
$Shortcut = $WScriptShell.CreateShortcut("$Startup\stc.lnk")
$Shortcut.TargetPath = $destinationPath
$Shortcut.Save()