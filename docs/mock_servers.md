Local mock servers for AMI and recordings

Two simple Dart mock servers are provided for local testing without Asterisk:

- `tools/ami_proxy_server.dart` — AMI proxy mock (port 8081)
- `tools/mock_recording_server.dart` — Recording server mock (port 8080)

There is also a configurable backend proxy intended as the next step toward a real AMI adapter:

- `tools/ami_backend_proxy.dart` — configurable AMI proxy (port 8081 by default). Run in simulate mode (default) or forward to a real AMI HTTP adapter using the `AMI_PROXY_FORWARD` environment variable.

Permission notes:

- The proxy supports a simple role header `x-user-role` for quick testing. For actions that create AMI jobs (`/ami/originate/listen`, `/ami/originate/playback`) the proxy requires `x-user-role` to be one of `supervisor`, `qa`, or `admin`. In production, parse and verify the JWT to derive roles.

DB migration:

- A sample SQL migration is available at `tools/migrations/001_create_audit_table.sql` to create an `ami_audit` table for persistent audit logging.

Examples:

```bash
# simulate mode (default)
dart run tools/ami_backend_proxy.dart

# proxy-forward mode (forward requests to an external AMI adapter service)
AMI_PROXY_FORWARD=http://ami-adapter:8080 dart run tools/ami_backend_proxy.dart
```

Requirements

- Dart SDK installed and on PATH

Run

```bash
dart run tools/ami_proxy_server.dart
dart run tools/mock_recording_server.dart
```

Notes

- `ami_proxy_server.dart` expects the frontend to send header `Authorization: Bearer test-token`.
- `mock_recording_server.dart` exposes `/recordings` and `/recordings/:id/stream` which redirects to a public sample MP3.
- When testing on Android emulator use `http://10.0.2.2:8080` for the recordings server and `http://10.0.2.2:8081` for the AMI proxy.

Quick test flows

- Play a recording from the app `CDR` page: the app calls `AmiApi.getRecordingMeta(uniqueId)` and falls back to `AmiApi.getRecordings()` (mock returns `rec1`).
- Start a Listen Live from `Extensions` → `Listen Live` will call `/ami/originate/listen` on the AMI proxy; the proxy simulates job states and SSE events.

If you want, I can add a small script to run both servers together.
