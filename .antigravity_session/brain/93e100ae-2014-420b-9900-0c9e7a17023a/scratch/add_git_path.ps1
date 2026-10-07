$gitCmd = "C:\Users\varun\AppData\Local\Programs\MinGit\cmd"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$gitCmd*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$gitCmd", "User")
    Write-Host "Added to User PATH."
} else {
    Write-Host "Already in User PATH."
}
$env:Path = "$env:Path;$gitCmd"
git --version
