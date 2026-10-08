param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Command
)
& ssh -i "$HOME\.ssh\id_ed25519" -o StrictHostKeyChecking=no labadmin@100.74.180.23 $Command
