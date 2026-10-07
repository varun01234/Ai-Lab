$pubKey = (Get-Content "$HOME\.ssh\id_ed25519.pub").Trim()
$env:SSH_ASKPASS = "c:\Users\varun\Downloads\AI-Lab\askpass.cmd"
$env:SSH_ASKPASS_REQUIRE = "force"
$env:DISPLAY = "1"
$remoteCmd = "mkdir -p ~/.ssh; chmod 700 ~/.ssh; echo '$pubKey' >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys; echo KEY_ADDED_SUCCESS"
& ssh -o StrictHostKeyChecking=no labadmin@100.74.180.23 $remoteCmd
