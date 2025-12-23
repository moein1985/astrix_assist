# Generation Configuration API

## Overview

The Generation Configuration system provides runtime and compile-time configuration for different Asterisk server generations (1-4). This allows the application to adapt to different Asterisk versions and their specific features.

## Core Classes

### `GenerationConfig` (Abstract Base Class)

```dart
abstract class GenerationConfig {
  // Identification
  int get generation;
  String get name;
  String get description;
  String get osName;
  String get osVersion;
  String get asteriskVersion;
  String get pythonVersion;

  // Paths
  String get cdrFilePath;
  String get recordingBasePath;
  String getRecordingPath(DateTime callDate);
  String get pythonScriptPath;

  // Features
  List<String> get supportedAmiCommands;
  List<String> get supportedRecordingFormats;
  bool get supportsCoreShowChannels;
  bool get supportsPJSIP;
  bool get supportsJSON;
  bool get supportsCEL;

  // CDR Configuration
  int get cdrColumnCount;
  List<String> get cdrColumns;
  bool get supportsTimezone;
  String get defaultTimezone;

  // SSH Configuration
  List<String> get supportedAuthMethods;
  int get defaultSSHPort;
  bool get requiresKeyAuth;
  bool get supports2FA;

  // AMI Configuration
  int get defaultAMIPort;
  String get amiVersion;

  // Python Configuration
  String get pythonPath;
  List<String> get sshOptions;
  List<String> get supportedPythonFeatures;
  List<String> get systemPaths;
}
```

### `AppConfig` (Main Configuration Manager)

```dart
class AppConfig {
  // Compile-time generation selector (1-4)
  static const int defaultGeneration = 4;

  // Runtime override (for testing)
  static int? _runtimeGeneration;

  // Get current active generation config
  static GenerationConfig get current {
    final gen = _runtimeGeneration ?? defaultGeneration;
    return getConfig(gen);
  }

  // Get config for specific generation
  static GenerationConfig getConfig(int generation);

  // Set generation at runtime (for testing)
  static void setGeneration(int gen);

  // Reset to default generation (for testing)
  static void resetGeneration();

  // Get all supported generations
  static List<int> get supportedGenerations => [1, 2, 3, 4];

  // Repository mode
  static const bool useMockRepositories = false;

  // Default connection settings
  static const String defaultSshHost = '192.168.1.100';
  static const int defaultSshPort = 22;
  static const String defaultSshUsername = 'asterisk';
  static const String defaultAmiHost = '192.168.1.100';
  static const int defaultAmiPort = 5038;
  static const String defaultAmiUsername = 'admin';
  static const String defaultAmiSecret = 'secret';
}
```

## Generation-Specific Implementations

### Generation 1: Legacy (CentOS 6 + Asterisk 11)
```dart
class Generation1Config extends GenerationConfig {
  @override
  int get generation => 1;
  @override
  String get name => 'Legacy';
  @override
  String get asteriskVersion => '11.x';
  @override
  bool get supportsCoreShowChannels => false;
  @override
  int get cdrColumnCount => 14;
}
```

### Generation 2: Transition (CentOS 7 + Asterisk 13)
```dart
class Generation2Config extends GenerationConfig {
  @override
  int get generation => 2;
  @override
  String get name => 'Transition';
  @override
  String get asteriskVersion => '13.x';
  @override
  bool get supportsCoreShowChannels => true;
  @override
  int get cdrColumnCount => 17;
}
```

### Generation 3: Modern (Rocky Linux 8 + Asterisk 16)
```dart
class Generation3Config extends GenerationConfig {
  @override
  int get generation => 3;
  @override
  String get name => 'Modern';
  @override
  String get asteriskVersion => '16.x';
  @override
  bool get supportsCoreShowChannels => true;
  @override
  int get cdrColumnCount => 19;
}
```

### Generation 4: Latest (Rocky Linux 9 + Asterisk 18/20)
```dart
class Generation4Config extends GenerationConfig {
  @override
  int get generation => 4;
  @override
  String get name => 'Latest';
  @override
  String get asteriskVersion => '18.x/20.x';
  @override
  bool get supportsCoreShowChannels => true;
  @override
  int get cdrColumnCount => 20;
}
```

## Usage Examples

### Compile-Time Configuration
```dart
// Change default generation in production
class AppConfig {
  static const int defaultGeneration = 3; // Use Generation 3
}
```

### Runtime Configuration (Testing Only)
```dart
import 'package:astrix_assist/core/app_config.dart';

void main() {
  // Set generation for testing
  AppConfig.setGeneration(2);

  // Your code...

  // Reset to default
  AppConfig.resetGeneration();
}
```

### Accessing Current Configuration
```dart
import 'package:astrix_assist/core/app_config.dart';

void example() {
  final config = AppConfig.current;

  print('Current generation: ${config.generation}');
  print('Asterisk version: ${config.asteriskVersion}');
  print('CDR columns: ${config.cdrColumnCount}');

  if (config.supportsCoreShowChannels) {
    // Use CoreShowChannels command
  }
}
```

## API Reference

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `generation` | `int` | Generation number (1-4) |
| `name` | `String` | Human-readable name |
| `asteriskVersion` | `String` | Supported Asterisk version |
| `cdrColumnCount` | `int` | Number of CDR columns |
| `supportsCoreShowChannels` | `bool` | Whether CoreShowChannels AMI command is supported |
| `supportsPJSIP` | `bool` | Whether PJSIP is supported |
| `supportsJSON` | `bool` | Whether JSON output is supported |
| `supportsCEL` | `bool` | Whether CEL (Channel Event Logging) is supported |

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `getRecordingPath(DateTime)` | `String` | Get recording path for specific date |
| `getConfig(int)` | `GenerationConfig` | Get config for specific generation |

## Error Handling

The system throws `ArgumentError` for invalid generation numbers:

```dart
AppConfig.setGeneration(5); // Throws ArgumentError
```

## Testing

Use runtime generation switching for testing different generations:

```dart
void main() {
  test('works with all generations', () {
    for (var gen in [1, 2, 3, 4]) {
      AppConfig.setGeneration(gen);
      final config = AppConfig.current;

      expect(config.generation, gen);
      // Test generation-specific behavior
    }
  });
}
```