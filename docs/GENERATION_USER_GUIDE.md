# Generation System User Guide

## Overview

The Astrix Assist application supports multiple Asterisk server generations (1-4) with different configurations, protocols, and features. This guide explains how to configure and use the generation system for both development and production environments.

## Supported Generations

### Generation 1: Legacy (CentOS 6 + Asterisk 11)
- **Timeline**: 2012-2015
- **OS**: CentOS 6.x
- **Asterisk**: 11.x LTS
- **Python**: 2.6
- **CDR Format**: 14 columns
- **Features**: Basic functionality, password-only SSH

### Generation 2: Transition (CentOS 7 + Asterisk 13)
- **Timeline**: 2015-2018
- **OS**: CentOS 7.x
- **Asterisk**: 13.x LTS
- **Python**: 2.7 / 3.4
- **CDR Format**: 17 columns
- **Features**: Extended AMI commands, key-based SSH

### Generation 3: Modern (Rocky Linux 8 + Asterisk 16)
- **Timeline**: 2018-2022
- **OS**: Rocky Linux 8.x
- **Asterisk**: 16.x LTS
- **Python**: 3.6+
- **CDR Format**: 19 columns + JSON
- **Features**: PJSIP support, JSON responses

### Generation 4: Latest (Rocky Linux 9 + Asterisk 18/20)
- **Timeline**: 2022-Present
- **OS**: Rocky Linux 9.x
- **Asterisk**: 18.x / 20.x LTS
- **Python**: 3.9+
- **CDR Format**: 20+ columns + CEL
- **Features**: Full feature set, 2FA support

## Configuration Methods

### Method 1: Compile-Time Configuration (Production)

For production deployments, set the default generation at compile time:

```dart
// File: lib/core/app_config.dart
class AppConfig {
  // Change this value for your deployment
  static const int defaultGeneration = 4; // For Rocky Linux 9 + Asterisk 18+
  // static const int defaultGeneration = 3; // For Rocky Linux 8 + Asterisk 16
  // static const int defaultGeneration = 2; // For CentOS 7 + Asterisk 13
  // static const int defaultGeneration = 1; // For CentOS 6 + Asterisk 11
}
```

**When to rebuild**: After changing the generation number, rebuild the application:

```bash
flutter clean
flutter pub get
flutter build apk  # or ios, web, etc.
```

### Method 2: Runtime Configuration (Testing Only)

For testing and development, you can switch generations at runtime:

```dart
import 'package:astrix_assist/core/app_config.dart';

void main() {
  // Switch to Generation 2 for testing
  AppConfig.setGeneration(2);

  // Your application code here...

  // Reset to default when done
  AppConfig.resetGeneration();
}
```

**⚠️ Warning**: Runtime generation switching is intended for testing only. Do not use in production code.

## Environment Variables

You can also control generation through environment variables:

```bash
# Set generation for flutter run
flutter run --dart-define=GENERATION=3

# Set generation for flutter build
flutter build apk --dart-define=GENERATION=3
```

In code, read the environment variable:

```dart
const generation = String.fromEnvironment('GENERATION', defaultValue: '4');
AppConfig.setGeneration(int.parse(generation));
```

## Determining Your Server Generation

### Method 1: Check Asterisk Version
```bash
# Connect to your Asterisk server
ssh user@asterisk-server

# Check Asterisk version
asterisk -V
# Output examples:
# Asterisk 11.25.3 -> Generation 1
# Asterisk 13.38.3 -> Generation 2
# Asterisk 16.30.0 -> Generation 3
# Asterisk 18.10.0 -> Generation 4
```

### Method 2: Check OS Version
```bash
# Check OS version
cat /etc/os-release

# CentOS 6.x -> Generation 1
# CentOS 7.x -> Generation 2
# Rocky Linux 8.x -> Generation 3
# Rocky Linux 9.x -> Generation 4
```

### Method 3: Check Python Version
```bash
# Check Python version
python --version
python3 --version

# Python 2.6 -> Generation 1
# Python 2.7/3.4 -> Generation 2
# Python 3.6+ -> Generation 3
# Python 3.9+ -> Generation 4
```

## Application Features by Generation

### CDR (Call Detail Records)

| Feature | Gen 1 | Gen 2 | Gen 3 | Gen 4 |
|---------|-------|-------|-------|-------|
| Columns | 14 | 17 | 19 | 20+ |
| Timezone | Basic | Full | Full | Full |
| JSON Support | ❌ | ❌ | ✅ | ✅ |
| CEL Support | ❌ | ❌ | ❌ | ✅ |

### AMI (Asterisk Manager Interface)

| Feature | Gen 1 | Gen 2 | Gen 3 | Gen 4 |
|---------|-------|-------|-------|-------|
| Version | 1.1 | 2.0 | 2.5 | 3.0 |
| CoreShowChannels | ❌ | ✅ | ✅ | ✅ |
| PJSIP Support | ❌ | ❌ | ✅ | ✅ |
| Advanced Actions | Limited | Extended | Full | Full |

### SSH Connection

| Feature | Gen 1 | Gen 2 | Gen 3 | Gen 4 |
|---------|-------|-------|-------|-------|
| Auth Methods | Password | Password+Key | Key Preferred | Key+2FA |
| Python Path | python | python/python3 | python3 | python3 |
| Recording Formats | WAV | WAV, GSM | WAV, GSM, MP3 | WAV, Opus, MP3, OGG |

## Testing with Different Generations

### Unit Testing
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  test('works with all generations', () {
    for (var gen in [1, 2, 3, 4]) {
      AppConfig.setGeneration(gen);

      final config = AppConfig.current;
      expect(config.generation, gen);

      // Test generation-specific behavior
      switch (gen) {
        case 1:
          expect(config.supportsCoreShowChannels, false);
          break;
        case 2:
        case 3:
        case 4:
          expect(config.supportsCoreShowChannels, true);
          break;
      }
    }
  });
}
```

### Integration Testing
```dart
import 'package:flutter_test/flutter_test.dart';
import '../../tools/mock_servers/mock_ssh_server.dart';
import '../../tools/mock_servers/mock_ami_server.dart';

void main() {
  for (var gen in [1, 2, 3, 4]) {
    group('Generation $gen', () {
      late MockSshServer sshServer;
      late MockAmiServer amiServer;

      setUpAll(() async {
        sshServer = MockSshServer(generation: gen, port: 2222 + gen);
        amiServer = MockAmiServer(generation: gen, port: 5038 + gen);

        await sshServer.start();
        await amiServer.start();
      });

      tearDownAll(() async {
        await sshServer.stop();
        await amiServer.stop();
      });

      test('CDR fetching works', () async {
        AppConfig.setGeneration(gen);
        // Test CDR operations for this generation
      });

      test('AMI commands work', () async {
        AppConfig.setGeneration(gen);
        // Test AMI operations for this generation
      });
    });
  }
}
```

## Troubleshooting

### Common Issues

#### 1. "Command not supported in this generation"
**Cause**: Using a feature not available in the current generation.
**Solution**: Check generation compatibility table above, or upgrade your Asterisk server.

#### 2. "Authentication failed"
**Cause**: Wrong authentication method for the generation.
**Solution**:
- Gen 1: Use password authentication only
- Gen 2+: Key-based authentication preferred
- Gen 4: May require 2FA

#### 3. "CDR parsing failed"
**Cause**: CDR format mismatch.
**Solution**: Verify generation matches your server, check CDR column count.

#### 4. "Python command not found"
**Cause**: Wrong Python executable path.
**Solution**: Check Python version and path for your generation.

### Debug Information
```dart
import 'package:astrix_assist/core/app_config.dart';

void printDebugInfo() {
  final config = AppConfig.current;

  print('Current Generation: ${config.generation}');
  print('Asterisk Version: ${config.asteriskVersion}');
  print('OS: ${config.osName} ${config.osVersion}');
  print('Python: ${config.pythonVersion}');
  print('CDR Columns: ${config.cdrColumnCount}');
  print('AMI Version: ${config.amiVersion}');
  print('Supports PJSIP: ${config.supportsPJSIP}');
  print('Supports JSON: ${config.supportsJSON}');
}
```

## Migration Guide

### Upgrading from Generation 1 to 2
1. Update Asterisk from 11.x to 13.x
2. Upgrade OS from CentOS 6 to CentOS 7
3. Change `defaultGeneration` from 1 to 2
4. Test AMI commands (CoreShowChannels now available)
5. Verify CDR parsing (17 columns instead of 14)

### Upgrading from Generation 2 to 3
1. Update Asterisk from 13.x to 16.x
2. Upgrade OS from CentOS 7 to Rocky Linux 8
3. Change `defaultGeneration` from 2 to 3
4. Enable PJSIP support if using PJSIP
5. Test JSON responses in AMI

### Upgrading from Generation 3 to 4
1. Update Asterisk from 16.x to 18.x/20.x
2. Upgrade OS from Rocky Linux 8 to 9
3. Change `defaultGeneration` from 3 to 4
4. Configure 2FA if required
5. Test CEL support for detailed call events

## Best Practices

1. **Test Thoroughly**: Always test with mock servers before deploying to production
2. **Version Pinning**: Pin your Asterisk and OS versions to stable releases
3. **Documentation**: Document your current generation in deployment scripts
4. **Monitoring**: Monitor for generation-specific errors in logs
5. **Backup**: Always backup configurations before generation changes

## Support

For issues specific to generation support:

1. Check this guide first
2. Review the API documentation in `docs/api/`
3. Test with mock servers: `dart tools/mock_servers/run_mock_servers.dart`
4. Check logs for generation-specific error messages
5. File issues with generation and Asterisk version information

## Changelog

### Version 1.0.0
- Initial release with Generation 1-4 support
- Basic compile-time and runtime configuration
- Mock server support for all generations
- Comprehensive testing framework