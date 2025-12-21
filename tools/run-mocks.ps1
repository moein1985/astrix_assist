# Run both mock servers (AMI proxy and recordings) in separate background jobs
# Requires Dart SDK available in PATH

$ami = Start-Job -ScriptBlock { dart run tools/ami_proxy_server.dart }
$rec = Start-Job -ScriptBlock { dart run tools/mock_recording_server.dart }

Write-Output "Started AMI proxy job Id: $($ami.Id) and recording server job Id: $($rec.Id)"
Write-Output "Use Get-Job | Receive-Job to see output, and Stop-Job -Id <id> to stop."