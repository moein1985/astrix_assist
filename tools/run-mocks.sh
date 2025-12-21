#!/usr/bin/env bash
# Run both mock servers in background (Unix/macOS)
# Requires Dart SDK

dart run tools/ami_proxy_server.dart &
AMI_PID=$!

dart run tools/mock_recording_server.dart &
REC_PID=$!

echo "AMI proxy PID: $AMI_PID"
echo "Recording server PID: $REC_PID"
echo "To stop: kill $AMI_PID $REC_PID"