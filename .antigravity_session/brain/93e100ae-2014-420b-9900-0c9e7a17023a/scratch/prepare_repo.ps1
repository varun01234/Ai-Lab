$env:Path = "$env:Path;C:\Users\varun\AppData\Local\Programs\MinGit\cmd"
$repoDir = "c:\Users\varun\Downloads\AI-Lab"
Set-Location $repoDir

# 1. Git Config
git config --global user.name "Varun Chaturvedi"
git config --global user.email "varunchaturvedi@example.com"
git config --global init.defaultBranch main

# 2. Git Init
if (-not (Test-Path "$repoDir\.git")) {
    git init
    Write-Host "Initialized empty Git repository."
}

# 3. .gitignore
$gitignoreContent = @"
# Ignore large model files & downloads
*.gguf
*.safetensors
*.bin
*.zip
*.tar.gz
*.aria2

# Ignore OS temp files
Thumbs.db
Desktop.ini
.DS_Store
"@
Set-Content -Path "$repoDir\.gitignore" -Value $gitignoreContent

# 4. Copy Antigravity Brain Session
$brainSource = "C:\Users\varun\.gemini\antigravity-ide\brain\93e100ae-2014-420b-9900-0c9e7a17023a"
$brainDest = "$repoDir\.antigravity_session\brain\93e100ae-2014-420b-9900-0c9e7a17023a"
if (-not (Test-Path $brainDest)) {
    New-Item -ItemType Directory -Force -Path $brainDest | Out-Null
}
Copy-Item -Path "$brainSource\*" -Destination $brainDest -Recurse -Force
Write-Host "Copied Antigravity session brain (Conversation ID: 93e100ae-2014-420b-9900-0c9e7a17023a)."

# 5. Create restore script for Office PC
$restoreScriptPs1 = @"
# Run this on your office PC after cloning this repository
`$convId = "93e100ae-2014-420b-9900-0c9e7a17023a"
`$targetBrain = "`$env:USERPROFILE\.gemini\antigravity-ide\brain\`$convId"
if (-not (Test-Path `$targetBrain)) {
    New-Item -ItemType Directory -Force -Path `$targetBrain | Out-Null
}
`$sourceBrain = "`$PSScriptRoot\.antigravity_session\brain\`$convId"
Copy-Item -Path "`$sourceBrain\*" -Destination `$targetBrain -Recurse -Force
Write-Host "Session successfully restored! Open Antigravity IDE to continue the exact same chat."
"@
Set-Content -Path "$repoDir\restore_session_on_office_pc.ps1" -Value $restoreScriptPs1

$restoreScriptBat = @"
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0restore_session_on_office_pc.ps1"
pause
"@
Set-Content -Path "$repoDir\restore_session_on_office_pc.bat" -Value $restoreScriptBat

# 6. Stage and Commit
git add .
git commit -m "feat: complete Qwen Daemon pre-model certification, staging pipeline, and Antigravity session state"
Write-Host "=== GIT STATUS ==="
git status
Write-Host "=== GIT LOG ==="
git log -n 1 --oneline
