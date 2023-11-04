# CONFIG
$dockerURL = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
$imageURL = "https://l.abstr.net/stcimage"
$stcURL = "https://l.abstr.net/stcbuildwindows"
$dockerConfig = @{
    imageName = "stc-image"
    containerName = "stc-container"
    # (OPTIONAL)
    # containerCreationCommand = "docker create -it --entrypoint `"/bin/sh`" --name containerName imageName -c `"tail -f /dev/null`""
}

## UAC
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

# ACCELERATE DOWNLOAD
$ProgressPreference = 'SilentlyContinue'

# DOCKER
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

# DOCKER SETTING
Write-Host "`nChanging settings of Docker Desktop"
$dockerSettingsPath = "$Env:APPDATA\Docker\settings.json"
if (Test-Path $dockerSettingsPath) {
    $jsonString = Get-Content $dockerSettingsPath -Raw
    $jsonObject = $jsonString | ConvertFrom-Json
    $jsonObject.openUIOnStartupDisabled = $false
    $jsonObject.autoStart = $true
    $jsonString = $jsonObject | ConvertTo-Json -Depth 10
    $jsonString | Set-Content $dockerSettingsPath
}
Write-Host "Installation done!"

# STC
$folderPath = "$env:APPDATA\save-the-choi"
if (Test-Path $folderPath) {
    Remove-Item -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
New-Item -Path $folderPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

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

# IMAGE
Write-Host "Downloading container image from $imageURL"
Invoke-WebRequest -Uri $imageURL -OutFile "$folderPath\image.tar"
Write-Host "Download done!"

# DOCKER CONFIG
$dockerConfigJson = $dockerConfig | ConvertTo-Json -Depth 10
$dockerConfigJson | Out-File -FilePath 'dockerConfig.json'

# REBOOT
while ($true) {
    Write-Host "Do you want to reboot now to complete the Docker Desktop installation? (Y/N)"
    $userInput = Read-Host
    if ($userInput -eq 'Y') {
        Restart-Computer
        Write-Host "System is rebooting..."
        break
    } elseif ($userInput -eq 'N') {
        Write-Host "Reboot canceled. Please reboot manually to complete the installation."
        break
    } else {
        Write-Host "Invalid input. Please enter 'Y' for Yes or 'N' for No."
    }
}