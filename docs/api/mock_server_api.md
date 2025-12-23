# Mock Server API

## Overview

The Mock Server system provides simulated SSH and AMI servers for testing different Asterisk generations without requiring actual Asterisk installations. This enables comprehensive testing of the application's interaction with various server configurations.

## Core Classes

### `MockSshServer` - SSH Server Simulation

```dart
class MockSshServer {
  final int generation;
  final int port;

  MockSshServer({
    required this.generation,
    this.port = 2222,
  });

  Future<void> start();
  Future<void> stop();
  bool get isRunning;
}
```

#### Features
- Simulates SSH protocol handshake
- Supports password authentication
- Executes mock commands based on generation
- Returns generation-specific responses
- Handles multiple concurrent connections

#### Supported Commands
```bash
# CDR Commands
python cdr --days 7 --limit 100
python3 cdr --days 7 --limit 100

# System Commands
uname -a
cat /etc/os-release
python --version

# File Operations
ls /var/spool/asterisk/monitor
find /var/spool/asterisk/monitor -name "*.wav"
```

### `MockAmiServer` - AMI Server Simulation

```dart
class MockAmiServer {
  final int generation;
  final int port;

  MockAmiServer({
    required this.generation,
    this.port = 5038,
  });

  Future<void> start();
  Future<void> stop();
  bool get isRunning;
}
```

#### Features
- Simulates AMI protocol
- Supports login/logout
- Returns generation-specific command responses
- Handles AMI action/response format
- Supports multiple AMI actions

#### Supported AMI Actions
```
Action: Login
Action: CoreShowChannels
Action: Status
Action: QueueStatus
Action: Originate
Action: Hangup
Action: Transfer
```

## Generation-Specific Behavior

### Generation 1 (Legacy)
- **SSH**: Basic Python 2.6, limited commands
- **AMI**: Basic AMI 1.1, minimal actions
- **CDR**: 14 columns, basic format

### Generation 2 (Transition)
- **SSH**: Python 2.7/3.4, extended commands
- **AMI**: AMI 2.0, more actions
- **CDR**: 17 columns, timezone support

### Generation 3 (Modern)
- **SSH**: Python 3.6+, full feature set
- **AMI**: AMI 2.5, advanced actions
- **CDR**: 19 columns, JSON support

### Generation 4 (Latest)
- **SSH**: Python 3.9+, 2FA support
- **AMI**: AMI 3.0, full feature set
- **CDR**: 20+ columns, CEL support

## Usage Examples

### Starting Mock Servers Programmatically
```dart
import 'package:astrix_assist/tools/mock_servers/mock_ssh_server.dart';
import 'package:astrix_assist/tools/mock_servers/mock_ami_server.dart';

void main() async {
  // Start servers for Generation 4
  final sshServer = MockSshServer(generation: 4, port: 2222);
  final amiServer = MockAmiServer(generation: 4, port: 5038);

  await Future.wait([
    sshServer.start(),
    amiServer.start(),
  ]);

  print('Mock servers running...');

  // Your tests here...

  // Stop servers
  await Future.wait([
    sshServer.stop(),
    amiServer.stop(),
  ]);
}
```

### Using Command Line Tool
```bash
# Start default servers (Generation 4)
dart tools/mock_servers/run_mock_servers.dart

# Start specific generation
dart tools/mock_servers/run_mock_servers.dart --generation 2

# Start with custom ports
dart tools/mock_servers/run_mock_servers.dart --ssh-port 2223 --ami-port 5040

# Start Generation 1 servers
dart tools/mock_servers/run_mock_servers.dart -g 1
```

### Integration Testing
```dart
import 'package:flutter_test/flutter_test.dart';
import '../../tools/mock_servers/mock_ssh_server.dart';
import '../../tools/mock_servers/mock_ami_server.dart';

void main() {
  late MockSshServer sshServer;
  late MockAmiServer amiServer;

  setUpAll(() async {
    sshServer = MockSshServer(generation: 4, port: 2222);
    amiServer = MockAmiServer(generation: 4, port: 5038);

    await sshServer.start();
    await amiServer.start();
  });

  tearDownAll(() async {
    await sshServer.stop();
    await amiServer.stop();
  });

  test('can connect to mock SSH server', () async {
    final socket = await Socket.connect('127.0.0.1', 2222);
    expect(socket.remotePort, 2222);
    await socket.close();
  });

  test('can connect to mock AMI server', () async {
    final socket = await Socket.connect('127.0.0.1', 5038);
    expect(socket.remotePort, 5038);
    await socket.close();
  });
}
```

## Response Formats

### SSH Command Responses
```bash
# Successful command
success: CDR data retrieved
total_records: 150
data: "2025-12-23 10:00:00","100","200",...

# Error response
error: Command failed: file not found

# System info
CentOS Linux release 7.9.2009 (Core)
Asterisk 13.38.3
Python 2.7.5
```

### AMI Responses
```
Asterisk Call Manager/2.10.4
Response: Success
ActionID: 12345
Message: Authentication accepted

Event: FullyBooted
Privilege: system,all
Status: Fully Booted

Response: Success
ActionID: 12346
Channel: SIP/100-0001
Context: default
State: Up
```

## Configuration Files

Mock servers use fixture files for realistic responses:

```
tools/mock_servers/fixtures/
├── generation_1/
│   ├── cdr_responses.json
│   ├── ami_responses.json
│   └── system_info.txt
├── generation_2/
│   ├── ...
└── ...
```

## Error Simulation

Mock servers can simulate various error conditions:

```dart
// Simulate connection timeout
final server = MockSshServer(generation: 4, port: 2222, simulateTimeout: true);

// Simulate authentication failure
final server = MockAmiServer(generation: 4, port: 5038, simulateAuthFailure: true);
```

## Performance Characteristics

- **Startup Time**: < 100ms
- **Response Time**: < 10ms per request
- **Concurrent Connections**: Up to 100 simultaneous connections
- **Memory Usage**: ~50MB per server instance

## Testing Best Practices

1. **Use setUpAll/tearDownAll** for server lifecycle
2. **Test connection establishment** before command execution
3. **Verify generation-specific responses**
4. **Test error conditions** and recovery
5. **Clean up connections** in tearDown

## Troubleshooting

### Common Issues

**Port already in use**
```bash
# Find process using port
netstat -ano | findstr :2222
# Kill process
taskkill /PID <pid> /F
```

**Connection refused**
- Ensure servers are started before tests
- Check firewall settings
- Verify correct ports

**Unexpected responses**
- Check generation parameter
- Verify fixture files exist
- Review test setup

## Integration with CI/CD

```yaml
# .github/workflows/test.yml
- name: Start Mock Servers
  run: dart tools/mock_servers/run_mock_servers.dart --generation 4 &

- name: Run Integration Tests
  run: flutter test test/integration/

- name: Stop Mock Servers
  run: pkill -f mock_servers
```