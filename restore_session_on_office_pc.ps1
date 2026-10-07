# Run this on your office PC after cloning this repository
$convId = "93e100ae-2014-420b-9900-0c9e7a17023a"
$targetBrain = "$env:USERPROFILE\.gemini\antigravity-ide\brain\$convId"
if (-not (Test-Path $targetBrain)) {
    New-Item -ItemType Directory -Force -Path $targetBrain | Out-Null
}
$sourceBrain = "$PSScriptRoot\.antigravity_session\brain\$convId"
Copy-Item -Path "$sourceBrain\*" -Destination $targetBrain -Recurse -Force
Write-Host "Session successfully restored! Open Antigravity IDE to continue the exact same chat."
