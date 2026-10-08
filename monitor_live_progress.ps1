# monitor_live_progress.ps1
# Continuously queries the VM for download progress and writes to LIVE_DOWNLOAD_MONITOR.log and LIVE_DOWNLOAD_STATUS.md

$logFile = "$PSScriptRoot\LIVE_DOWNLOAD_MONITOR.log"
$mdFile = "$PSScriptRoot\LIVE_DOWNLOAD_STATUS.md"
$sshKey = "$HOME\.ssh\id_ed25519"
$targetHost = "labadmin@100.74.180.23"

$header = @"
========================================================================================
  AI-LAB MODEL JAIL LIVE DOWNLOAD MONITOR & AUDIT LOG
  Target Jail: /srv/nwa-model/models
  Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
========================================================================================
"@

if (-not (Test-Path $logFile)) {
    Set-Content -Path $logFile -Value $header
} else {
    Add-Content -Path $logFile -Value "`n$header"
}

while ($true) {
    $timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    
    try {
        $jsonStr = & ssh -n -i $sshKey -o StrictHostKeyChecking=no $targetHost "python3 /home/labadmin/status_collector.py" 2>$null
        if ($jsonStr) {
            $data = $jsonStr | ConvertFrom-Json
            
            $streamInfo = $data.latest_stream_info
            $diskUsage = $data.disk
            $what = $data.what_is_happening
            $m27Gib = $data.m27.gib
            $m27Tot = $data.m27.total_gib
            $m27Pct = $data.m27.pct
            $m30Gib = $data.m30.gib
            $m30Tot = $data.m30.total_gib
            $m30Pct = $data.m30.pct
            $w8Count = $data.w8.files_count
            $w8Gib = $data.w8.gib
            $w8Tot = $data.w8.total_gib
            $w8Pct = $data.w8.pct
            
            $ariaActiveStr = if ($data.aria2_active) { "🟢 Active (PID $($data.aria2_pid))" } else { "🟡 Idle / Transition" }
            $m27StatusStr = if ($data.m27.done) { "✅ COMPLETE" } else { "⏳ DOWNLOADING" }
            $m30StatusStr = if ($data.m30.done) { "✅ COMPLETE" } elseif ($data.m27.done) { if ($data.aria2_active) {"⏳ DOWNLOADING"} else {"⏸️ PAUSED"} } else { "⏸️ QUEUED" }
            $w8StatusStr = if ($data.w8.done) { "✅ COMPLETE" } elseif ($data.m30.done) { if ($data.aria2_active) {"⏳ DOWNLOADING"} else {"⏸️ PAUSED"} } else { "⏸️ QUEUED" }
            $w8PctStr = if ($data.w8.done) { "100%" } elseif ($data.w8.pct) { "$($data.w8.pct)%" } else { "--" }

            $w8Display = if ($w8Gib) { "$w8Gib GiB / $w8Tot GiB ($w8Pct% complete, $w8Count files)" } else { "$w8Count files staged" }

            $logEntry = "[$timestamp] [STAGE: $($data.stage)]`n  STATUS: $what`n  STREAM: $streamInfo`n  ARIA2: $(if ($data.aria2_active) {"RUNNING (PID $($data.aria2_pid))"} else {'IDLE/TRANSITIONING'})`n  27B Model: $m27Gib GiB / $m27Tot GiB ($m27Pct% complete)`n  30B Model: $m30Gib GiB / $m30Tot GiB ($m30Pct% complete)`n  8B Model:  $w8Display`n  DISK:      $diskUsage`n----------------------------------------------------------------------------------------"
            
            Add-Content -Path $logFile -Value $logEntry
            
            # Update Markdown Dashboard
            $mdContent = @"
# AI-Lab Model Download Live Dashboard

**Last Updated:** $timestamp

### Current Milestone & Action
> **$what**

| Model | Jail Path | Transferred / Total | Progress | Status |
| :--- | :--- | :--- | :--- | :--- |
| **1. 27B Main** | `/srv/nwa-model/models/main-27b/` | $m27Gib GiB / $m27Tot GiB | **$m27Pct%** | $m27StatusStr |
| **2. 30B Coder** | `/srv/nwa-model/models/coder-30b/` | $m30Gib GiB / $m30Tot GiB | **$m30Pct%** | $m30StatusStr |
| **3. 8B Worker** | `/srv/nwa-model/models/worker-8b/` | $(if ($w8Gib) {"$w8Gib GiB / $w8Tot GiB ($w8Count files)"} else {"$w8Count files staged"}) | **$w8PctStr** | $w8StatusStr |

### Process & Storage Health
- **aria2c Daemon:** $ariaActiveStr
- **Stream Metrics:** $streamInfo
- **Model Jail Disk Usage:** $diskUsage
- **Security Mode:** Inactive Quarantine Jail (`chmod 750 dirs, chmod 640 files, root:nwa-model`)
"@
            Set-Content -Path $mdFile -Value $mdContent -Force
        }
    } catch {
        Add-Content -Path $logFile -Value "[$timestamp] Check warning: $($_.Exception.Message)"
    }
    
    Start-Sleep -Seconds 6
}
