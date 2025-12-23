# Adapter API

## Overview

The Adapter system provides a unified interface for interacting with different Asterisk server generations. Adapters handle the differences in protocols, commands, and data formats across generations 1-4.

## Core Adapters

### `AMIAdapter` - Asterisk Manager Interface Adapter

```dart
class AMIAdapter {
  final GenerationConfig _config = AppConfig.current;

  /// Adapts an AMI command for the current generation
  String adaptCommand(String command);

  /// Parses an AMI response for the current generation
  Map<String, dynamic> parseResponse(String response);

  /// Gets the login command for the current generation
  String getLoginCommand(String username, String password);

  /// Checks if a response indicates success for the current generation
  bool isSuccessResponse(String response);

  /// Gets the logout command for the current generation
  String getLogoutCommand();

  /// Adapts an AMI response based on command type for the current generation
  Map<String, dynamic> adaptResponse(String command, String response);
}
```

#### Usage Example
```dart
final amiAdapter = AMIAdapter();

// Login to AMI
final loginCommand = amiAdapter.getLoginCommand('admin', 'secret');
final response = await sendCommand(loginCommand);
final isSuccess = amiAdapter.isSuccessResponse(response);

// Execute a command
final adaptedCommand = amiAdapter.adaptCommand('CoreShowChannels');
final result = amiAdapter.parseResponse(await sendCommand(adaptedCommand));
```

### `CDRAdapter` - Call Detail Record Adapter

```dart
class CDRAdapter {
  final GenerationConfig _config = AppConfig.current;

  /// Parses a CDR line according to the current generation's format
  Map<String, dynamic> parseCDR(String cdrLine);

  /// Formats a CDR map back to string format for the current generation
  String formatCDR(Map<String, dynamic> cdrData);

  /// Gets the expected CDR columns for the current generation
  List<String> getCDRColumns();

  /// Validates if a CDR line matches the expected format for the current generation
  bool validateCDRFormat(String cdrLine);

  /// Gets the CDR file path for the current generation
  String getCDRFilePath();

  /// Adapts CDR data from one generation format to another if needed
  Map<String, dynamic> adaptCDRData(Map<String, dynamic> cdrData, int targetGeneration);
}
```

#### Usage Example
```dart
final cdrAdapter = CDRAdapter();

// Parse a CDR line
final cdrLine = '"2025-12-23 10:00:00","100","200","default","SIP/100-0001","SIP/200-0002","Dial","SIP/200,30,Tt","45","42","ANSWERED","3","1734945600.1",""';
final parsedCDR = cdrAdapter.parseCDR(cdrLine);

// Validate format
final isValid = cdrAdapter.validateCDRFormat(cdrLine);

// Get columns
final columns = cdrAdapter.getCDRColumns();
```

### `SSHAdapter` - SSH Connection Adapter

```dart
class SSHAdapter {
  final GenerationConfig _config = AppConfig.current;

  /// Gets the SSH connection parameters for the current generation
  Map<String, dynamic> getConnectionParams({
    required String host,
    required int port,
    required String username,
    String? password,
    String? keyPath,
  });

  /// Adapts a command for execution on the current generation's system
  String adaptCommand(String command);

  /// Gets the Python executable path for the current generation
  String getPythonExecutable();

  /// Checks if the current generation supports a specific Python feature
  bool supportsPythonFeature(String feature);

  /// Gets the system paths that should be available for the current generation
  List<String> getSystemPaths();

  /// Validates that the remote system matches the expected generation
  Future<bool> validateGeneration();
}
```

#### Usage Example
```dart
final sshAdapter = SSHAdapter();

// Get connection parameters
final params = sshAdapter.getConnectionParams(
  host: '192.168.1.100',
  port: 22,
  username: 'asterisk',
  password: 'password123',
);

// Adapt a command
final adaptedCommand = sshAdapter.adaptCommand('python3 cdr_script.py --days 7');

// Check Python features
if (sshAdapter.supportsPythonFeature('async')) {
  // Use async features
}
```

## Generation-Specific Behavior

### Generation Differences

| Feature | Gen 1 | Gen 2 | Gen 3 | Gen 4 |
|---------|-------|-------|-------|-------|
| AMI Commands | Basic | Extended | Full | Advanced |
| CDR Columns | 14 | 17 | 19 | 20+ |
| Python Version | 2.6 | 2.7/3.4 | 3.6+ | 3.9+ |
| SSH Auth | Password | Password+Key | Key preferred | Key+2FA |

### AMI Command Adaptation
```dart
// Generation 1: Limited commands
amiAdapter.adaptCommand('CoreShowChannels'); // May not be supported

// Generation 2+: Full command set
amiAdapter.adaptCommand('CoreShowChannels'); // Fully supported
```

### CDR Format Adaptation
```dart
// Generation 1: 14 columns
cdrAdapter.getCDRColumns().length; // Returns 14

// Generation 4: 20+ columns
cdrAdapter.getCDRColumns().length; // Returns 20+
```

### SSH Command Adaptation
```dart
// Generation 1: Python 2.6
sshAdapter.adaptCommand('python script.py'); // Uses python2

// Generation 4: Python 3.9+
sshAdapter.adaptCommand('python script.py'); // Uses python3
```

## Error Handling

Adapters throw specific exceptions for generation incompatibilities:

```dart
try {
  final result = amiAdapter.adaptCommand('UnsupportedCommand');
} on UnsupportedError catch (e) {
  print('Command not supported in current generation: ${e.message}');
}
```

## Testing with Adapters

```dart
void main() {
  test('AMI adapter works across generations', () {
    for (var gen in [1, 2, 3, 4]) {
      AppConfig.setGeneration(gen);
      final adapter = AMIAdapter();

      final loginCmd = adapter.getLoginCommand('admin', 'secret');
      expect(loginCmd, isNotEmpty);
    }
  });

  test('CDR adapter parses correctly', () {
    for (var gen in [1, 2, 3, 4]) {
      AppConfig.setGeneration(gen);
      final adapter = CDRAdapter();

      final testLine = getTestCDRLineForGeneration(gen);
      final parsed = adapter.parseCDR(testLine);
      expect(parsed, isNotEmpty);
    }
  });
}
```

## Performance Considerations

- Adapters cache generation-specific data to avoid repeated lookups
- Command adaptation is done at runtime for flexibility
- Parsing operations are optimized for the specific generation format

## Integration with Dependency Injection

Adapters are typically instantiated as needed and use the current `AppConfig.current` configuration:

```dart
// In dependency injection setup
sl.registerFactory(() => AMIAdapter());
sl.registerFactory(() => CDRAdapter());
sl.registerFactory(() => SSHAdapter());
```

This ensures adapters always use the most current generation configuration.