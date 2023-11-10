# CONFIG
$dockerURL = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
$imageURL = "https://l.hpclab.kr/stcimage"
$stcURL = "https://l.hpclab.kr/stcbuildwindows"
$dockerConfig = @{
    imageName = "stc-image"
    containerName = "stc-container"
}

## UAC
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
& "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
do {
    $dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowTitle -ne "" }
    Start-Sleep -Milliseconds 100
} while ($null -eq $dockerProcess)
$dockerProcess.CloseMainWindow() | Out-Null

$dockerSettingsPath = "$Env:APPDATA\Docker\settings.json"
do {
    $fileExists = Test-Path $dockerSettingsPath
    Start-Sleep -Seconds 1
} while (-not $fileExists)
if (Test-Path $dockerSettingsPath) {
    $jsonString = Get-Content $dockerSettingsPath -Raw
    $jsonObject = $jsonString | ConvertFrom-Json
    $jsonObject.openUIOnStartupDisabled = $true
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
$dockerConfigJson | Out-File -Encoding utf8 -FilePath "$folderPath\docker-config.json"

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