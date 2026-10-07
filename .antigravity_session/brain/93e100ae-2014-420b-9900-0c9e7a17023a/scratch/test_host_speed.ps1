$sw = [System.Diagnostics.Stopwatch]::StartNew()
$wc = New-Object System.Net.WebClient
try {
    $data = $wc.DownloadData("https://speed.cloudflare.com/__down?bytes=5000000")
    $sw.Stop()
    $speedKB = ($data.Length / $sw.Elapsed.TotalSeconds) / 1024
    $speedMbps = ($speedKB * 8) / 1024
    Write-Host "Host Speed: $([math]::Round($speedKB, 2)) KB/s ($([math]::Round($speedMbps, 2)) Mbps)"
} catch {
    Write-Host "Error: $_"
}
