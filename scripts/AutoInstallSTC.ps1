$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

if ($myWindowsPrincipal.IsInRole($adminRole))
{
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
    $Host.UI.RawUI.BackgroundColor = "DarkBlue";
	Clear-Host;
}
else {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    Exit;
}


$ProgressPreference = 'SilentlyContinue'

$dockerURL = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
Write-Host "Downloading Docker Desktop Installer from $dockerURL"
$dockerTempPath = "$env:TEMP\docker-desktop-installer.exe"
Invoke-WebRequest -Uri $dockerURL -OutFile $dockerTempPath
Write-Host "Download done!"

Write-Host -NoNewline "Installing Docker Desktop"
& $dockerTempPath install --quiet --accept-license

while (Get-Process | Where-Object { $_.Name -like 'docker-desktop-installer' }) {
	Start-Sleep -Seconds 1
	Write-Host -NoNewline "."
}
Write-Host "`nInstallation done!"

$folderPath = "C:\Program Files\Save the Choi"
if (Test-Path $folderPath) {
    Remove-Item -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $folderPath -ItemType Directory -ErrorAction SilentlyContinue

$stcURL = "http://h.abstr.net:7070/stc.exe"
Write-Host "Downloading Save the Choi from $stcURL"
$destinationPath = "$folderPath\stc.exe"
Invoke-WebRequest -Uri $stcURL -OutFile $destinationPath
Write-Host "Download done!"

Write-Host "Registering Save the Choi with the startup program..."
$WScriptShell = New-Object -ComObject WScript.Shell
$Startup = $WScriptShell.SpecialFolders('Startup')
$Shortcut = $WScriptShell.CreateShortcut("$Startup\stc.lnk")
$Shortcut.TargetPath = $destinationPath
$Shortcut.Save()

Write-Host "After 10 seconds, a reboot will proceed to complete the Docker Desktop installation."
for ($i=10; $i -gt 0; $i--) {
    Write-Host "$i"
    Start-Sleep -Seconds 1
}
Restart-Computer