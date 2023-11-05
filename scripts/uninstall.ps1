$folderPath = "$env:APPDATA\save-the-choi"
if (Test-Path $folderPath) {
    Remove-Item -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\stc.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "Uninstall done!"