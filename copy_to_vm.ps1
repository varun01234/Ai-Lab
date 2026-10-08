param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$SourceFile,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$RemoteDest
)
& scp -i "$HOME\.ssh\id_ed25519" -o StrictHostKeyChecking=no $SourceFile "labadmin@100.74.180.23:$RemoteDest"
