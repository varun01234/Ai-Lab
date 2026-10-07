$os = Get-CimInstance Win32_OperatingSystem
$totalHost = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeHost = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
Write-Host "Host Total RAM: $totalHost GB"
Write-Host "Host Free RAM: $freeHost GB"

try {
    $vms = Get-VM
    foreach ($vm in $vms) {
        Write-Host "VM Name: $($vm.Name), State: $($vm.State), MemoryAssigned: $($vm.MemoryAssigned / 1GB) GB, MemoryStartup: $($vm.MemoryStartup / 1GB) GB"
    }
} catch {
    Write-Host "Hyper-V Cmdlet Note: $_"
}
