$env:SSH_ASKPASS = "c:\Users\varun\Downloads\AI-Lab\askpass.cmd"
$env:SSH_ASKPASS_REQUIRE = "force"
$env:DISPLAY = "1"
& ssh -o StrictHostKeyChecking=no labadmin@100.74.180.23 "echo CONNECTED_SUCCESSFULLY"
