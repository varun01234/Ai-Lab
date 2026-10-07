$destDir = "C:\Users\varun\AppData\Local\Programs\MinGit"
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
}
$zipPath = "C:\Users\varun\AppData\Local\Temp\mingit.zip"
Write-Host "Downloading MinGit..."
Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/MinGit-2.47.1-64-bit.zip" -OutFile $zipPath
Write-Host "Extracting MinGit..."
Expand-Archive -Path $zipPath -DestinationPath $destDir -Force
Remove-Item -Force $zipPath

$gitExe = "$destDir\cmd\git.exe"
if (Test-Path $gitExe) {
    Write-Host "MinGit successfully installed:"
    & $gitExe --version
} else {
    Write-Host "MinGit installation failed."
}
