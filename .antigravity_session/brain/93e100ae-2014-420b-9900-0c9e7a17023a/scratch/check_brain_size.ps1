$source = "C:\Users\varun\.gemini\antigravity-ide\brain\93e100ae-2014-420b-9900-0c9e7a17023a"
$items = Get-ChildItem -Path $source -Recurse
$totalSize = ($items | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Brain Directory Total Size: $([math]::Round($totalSize, 2)) MB ($($items.Count) files)"
