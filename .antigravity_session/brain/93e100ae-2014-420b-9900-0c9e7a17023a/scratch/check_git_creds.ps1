$env:Path = "$env:Path;C:\Users\varun\AppData\Local\Programs\MinGit\cmd"
Write-Host "=== SSH KEYS IN .ssh ==="
Get-ChildItem -Path "C:\Users\varun\.ssh" -ErrorAction SilentlyContinue | Select-Object -Property Name, Length

Write-Host "=== GIT CONFIG ==="
git config --global --list

Write-Host "=== CREDENTIAL MANAGER ENTRIES ==="
cmdkey /list | Select-String "git"
