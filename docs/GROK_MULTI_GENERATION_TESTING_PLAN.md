# 🎯 Grok AI - Multi-Generation Testing Framework Implementation Plan

## 📋 خلاصه پروژه

ساخت یک سیستم تست و mock repository کامل برای 4 نسل مختلف Linux/Asterisk در پروژه Astrix Assist.

**تاریخ شروع**: 23 دسامبر 2025  
**زمان تخمینی**: 2-3 روز کاری  
**اولویت**: بالا

---

## 🎯 اهداف نهایی

- ✅ پشتیبانی از 4 نسل مختلف Asterisk (11, 13, 16, 18+)
- ✅ ساخت Mock Server کامل برای SSH و AMI
- ✅ ایجاد Test Fixtures با داده‌های واقعی
- ✅ پوشش کامل Unit Tests (80%+)
- ✅ پوشش کامل Widget Tests (70%+)
- ✅ پوشش Integration Tests (60%+)
- ✅ Configuration System با Runtime/Compile-time switching

---

## 📊 نسل‌های مورد پشتیبانی

### Generation 1: Legacy (CentOS 6 + Asterisk 11)
```yaml
Timeline: 2012-2015
Python: 2.6
OS: CentOS 6.x
Asterisk: 11.x LTS
CDR Format: 14 columns
AMI Version: 1.1
Recording: WAV only
SSH: Password auth
Timezone: Naive
```

### Generation 2: Transition (CentOS 7 + Asterisk 13)
```yaml
Timeline: 2015-2018
Python: 2.7 / 3.4
OS: CentOS 7.x
Asterisk: 13.x LTS
CDR Format: 17 columns
AMI Version: 2.0
Recording: WAV, GSM
SSH: Password + Key
Timezone: Basic support
```

### Generation 3: Modern (Rocky Linux 8 + Asterisk 16)
```yaml
Timeline: 2018-2022
Python: 3.6+
OS: Rocky Linux 8.x
Asterisk: 16.x LTS
CDR Format: 19 columns + JSON
AMI Version: 2.5
Recording: WAV, GSM, MP3
SSH: Key preferred
Timezone: Full support
```

### Generation 4: Latest (Rocky Linux 9 + Asterisk 18/20)
```yaml
Timeline: 2022-Present
Python: 3.9+
OS: Rocky Linux 9.x
Asterisk: 18.x / 20.x LTS
CDR Format: 20+ columns + JSON + CEL
AMI Version: 3.0
Recording: WAV, Opus, MP3, OGG
SSH: Key + 2FA support
Timezone: Full with DST
```

---

## 🔍 PHASE 1: RESEARCH & DOCUMENTATION

### Task 1.1: Research Asterisk AMI Differences
**مدت زمان**: 4 ساعت  
**منابع**:
- https://docs.asterisk.org/Asterisk_11_Documentation/API_Documentation/AMI/
- https://docs.asterisk.org/Asterisk_13_Documentation/API_Documentation/AMI/
- https://docs.asterisk.org/Asterisk_16_Documentation/API_Documentation/AMI/
- https://wiki.asterisk.org/wiki/display/AST/Asterisk+20+Documentation

**وظایف**:
1. استخراج لیست Commands مشترک و متفاوت
2. بررسی Response Format برای هر نسخه
3. شناسایی Breaking Changes
4. مستندسازی در `docs/asterisk_ami_comparison.md`

**خروجی مورد انتظار**:
```markdown
# Asterisk AMI Command Comparison

## Generation 1 (Asterisk 11)
### Available Commands
- Login
- Logoff
- SIPpeers
- SIPshowpeer
- QueueStatus (basic)
- Status
- Command

### NOT Available
- CoreShowChannels
- PJSIP commands
- JSON responses

## Generation 2 (Asterisk 13)
...
```

---

### Task 1.2: Research CDR Format Differences
**مدت زمان**: 3 ساعت  
**منابع**:
- /var/log/asterisk/cdr-csv/Master.csv
- https://docs.asterisk.org/Configuration/Reporting/Call-Detail-Records-CDR/

**وظایف**:
1. بررسی تعداد ستون‌ها در هر نسخه
2. شناسایی فیلدهای جدید/حذف شده
3. بررسی فرمت تاریخ و timezone
4. مستندسازی در `docs/cdr_format_comparison.md`

**خروجی مورد انتظار**:
```markdown
# CDR Format Comparison

## Generation 1 (14 columns)
1. accountcode
2. src
3. dst
4. dcontext
5. clid
6. channel
7. dstchannel
8. lastapp
9. lastdata
10. calldate (no timezone)
11. duration
12. billsec
13. disposition
14. amaflags

## Generation 2 (17 columns)
...
```

---

### Task 1.3: Research SSH & Python Differences
**مدت زمان**: 2 ساعت  

**وظایف**:
1. بررسی Python 2.6 vs 2.7 vs 3.6 vs 3.9
2. شناسایی تفاوت‌های syntax و libraries
3. بررسی SSH authentication methods
4. مستندسازی در `docs/ssh_python_comparison.md`

---

### Task 1.4: Create Generation Specification Document
**مدت زمان**: 2 ساعت  

**خروجی**: `docs/generation_specifications.md` با جزئیات کامل هر نسل

---

## 🏗️ PHASE 2: CONFIGURATION SYSTEM

### Task 2.1: Create Generation Config Interface
**مدت زمان**: 3 ساعت  
**فایل**: `lib/core/generation/generation_config.dart`

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
  
  // Python Script Configuration
  String getPythonCommand();
  Map<String, String> getPythonScriptArgs();
  
  // Compatibility Methods
  String adaptAMICommand(String command);
  Map<String, dynamic> adaptAMIResponse(Map<String, dynamic> response);
  Map<String, dynamic> adaptCDRRecord(Map<String, dynamic> record);
  
  // Validation
  bool isCommandSupported(String command);
  bool isFeatureSupported(String feature);
}
```

---

### Task 2.2: Implement Generation Configs
**مدت زمان**: 6 ساعت  
**فایل‌ها**:
- `lib/core/generation/generation_1_config.dart`
- `lib/core/generation/generation_2_config.dart`
- `lib/core/generation/generation_3_config.dart`
- `lib/core/generation/generation_4_config.dart`

**نمونه**: `generation_1_config.dart`

```dart
import 'generation_config.dart';

class Generation1Config implements GenerationConfig {
  @override
  int get generation => 1;
  
  @override
  String get name => 'Legacy';
  
  @override
  String get description => 'CentOS 6 + Asterisk 11 (2012-2015)';
  
  @override
  String get osName => 'CentOS';
  
  @override
  String get osVersion => '6.x';
  
  @override
  String get asteriskVersion => '11.x';
  
  @override
  String get pythonVersion => '2.6';
  
  @override
  String get cdrFilePath => '/var/log/asterisk/cdr-csv/Master.csv';
  
  @override
  String get recordingBasePath => '/var/spool/asterisk/monitor';
  
  @override
  String getRecordingPath(DateTime callDate) {
    // Generation 1: No date subdirectories
    return recordingBasePath;
  }
  
  @override
  List<String> get supportedAmiCommands => [
    'Login',
    'Logoff',
    'SIPpeers',
    'SIPshowpeer',
    'QueueStatus',
    'Status',
    'Command',
  ];
  
  @override
  bool get supportsCoreShowChannels => false;
  
  @override
  bool get supportsPJSIP => false;
  
  @override
  bool get supportsJSON => false;
  
  @override
  bool get supportsCEL => false;
  
  @override
  int get cdrColumnCount => 14;
  
  @override
  List<String> get cdrColumns => [
    'accountcode',
    'src',
    'dst',
    'dcontext',
    'clid',
    'channel',
    'dstchannel',
    'lastapp',
    'lastdata',
    'calldate',
    'duration',
    'billsec',
    'disposition',
    'amaflags',
  ];
  
  @override
  bool get supportsTimezone => false;
  
  @override
  String get defaultTimezone => 'UTC';
  
  @override
  List<String> get supportedAuthMethods => ['password'];
  
  @override
  bool get requiresKeyAuth => false;
  
  @override
  bool get supports2FA => false;
  
  @override
  String getPythonCommand() => 'python2.6';
  
  @override
  String adaptAMICommand(String command) {
    // Asterisk 11 doesn't support CoreShowChannels
    if (command == 'CoreShowChannels') {
      return 'Status'; // Fallback to Status
    }
    return command;
  }
  
  @override
  Map<String, dynamic> adaptCDRRecord(Map<String, dynamic> record) {
    // Add missing fields for compatibility
    return {
      ...record,
      'uniqueid': record['uniqueid'] ?? '',
      'userfield': record['userfield'] ?? '',
      'answerdate': record['answerdate'] ?? '',
      'enddate': record['enddate'] ?? '',
    };
  }
}
```

---

### Task 2.3: Update AppConfig
**مدت زمان**: 2 ساعت  
**فایل**: `lib/core/app_config.dart`

```dart
import 'generation/generation_config.dart';
import 'generation/generation_1_config.dart';
import 'generation/generation_2_config.dart';
import 'generation/generation_3_config.dart';
import 'generation/generation_4_config.dart';

class AppConfig {
  // Compile-time generation selector (1-4)
  // تغییر این عدد برای انتخاب نسل پیش‌فرض
  static const int defaultGeneration = 4; // Rocky 9 + Asterisk 18+
  
  // Runtime override (برای testing)
  static int? _runtimeGeneration;
  
  // Singleton instance cache
  static final Map<int, GenerationConfig> _configCache = {};
  
  /// Get current active generation config
  static GenerationConfig get current {
    final gen = _runtimeGeneration ?? defaultGeneration;
    return getConfig(gen);
  }
  
  /// Get config for specific generation
  static GenerationConfig getConfig(int generation) {
    if (!_configCache.containsKey(generation)) {
      _configCache[generation] = _createConfig(generation);
    }
    return _configCache[generation]!;
  }
  
  static GenerationConfig _createConfig(int gen) {
    switch (gen) {
      case 1:
        return Generation1Config();
      case 2:
        return Generation2Config();
      case 3:
        return Generation3Config();
      case 4:
        return Generation4Config();
      default:
        throw ArgumentError(
          'Invalid generation: $gen. Must be between 1 and 4.',
        );
    }
  }
  
  /// Set generation at runtime (برای testing)
  /// 
  /// توجه: این متد فقط در محیط test استفاده می‌شود
  /// در production از defaultGeneration استفاده می‌شود
  static void setGeneration(int gen) {
    if (gen < 1 || gen > 4) {
      throw ArgumentError('Generation must be between 1 and 4');
    }
    _runtimeGeneration = gen;
    _configCache.clear(); // Clear cache on generation change
  }
  
  /// Reset to default generation (برای testing)
  static void resetGeneration() {
    _runtimeGeneration = null;
    _configCache.clear();
  }
  
  /// Get all supported generations
  static List<int> get supportedGenerations => [1, 2, 3, 4];
  
  /// Check if generation is supported
  static bool isGenerationSupported(int gen) {
    return gen >= 1 && gen <= 4;
  }
  
  /// Get generation info
  static String getGenerationInfo(int gen) {
    return getConfig(gen).description;
  }
}
```

---

## 🔌 PHASE 3: ADAPTER LAYER

### Task 3.1: Create AMI Adapter
**مدت زمان**: 4 ساعت  
**فایل**: `lib/core/adapters/ami_adapter.dart`

```dart
import '../generation/generation_config.dart';
import '../app_config.dart';

/// Adapter for AMI commands to handle generation differences
class AmiAdapter {
  final GenerationConfig config;
  
  AmiAdapter(this.config);
  
  factory AmiAdapter.current() => AmiAdapter(AppConfig.current);
  
  /// Adapt command before sending to AMI
  String adaptCommand(String command) {
    return config.adaptAMICommand(command);
  }
  
  /// Adapt response after receiving from AMI
  Map<String, dynamic> adaptResponse(
    String command,
    Map<String, dynamic> response,
  ) {
    return config.adaptAMIResponse(response);
  }
  
  /// Check if command is supported
  bool isCommandSupported(String command) {
    return config.isCommandSupported(command);
  }
  
  /// Get active calls with generation-aware logic
  Future<List<Map<String, dynamic>>> getActiveCalls(
    Function(String) sendCommand,
  ) async {
    if (config.supportsCoreShowChannels) {
      // Modern Asterisk: Use CoreShowChannels
      final response = await sendCommand('CoreShowChannels');
      return _parseCoreShowChannels(response);
    } else {
      // Legacy Asterisk: Use Status
      final response = await sendCommand('Status');
      return _parseStatus(response);
    }
  }
  
  List<Map<String, dynamic>> _parseCoreShowChannels(dynamic response) {
    // Parse CoreShowChannels response
    // ...
  }
  
  List<Map<String, dynamic>> _parseStatus(dynamic response) {
    // Parse Status response (legacy format)
    // ...
  }
}
```

---

### Task 3.2: Create SSH Adapter
**مدت زمان**: 3 ساعت  
**فایل**: `lib/core/adapters/ssh_adapter.dart`

```dart
import '../generation/generation_config.dart';
import '../app_config.dart';

class SshAdapter {
  final GenerationConfig config;
  
  SshAdapter(this.config);
  
  factory SshAdapter.current() => SshAdapter(AppConfig.current);
  
  /// Get Python command for executing scripts
  String getPythonCommand() {
    return config.getPythonCommand();
  }
  
  /// Get CDR script command with generation-specific args
  String getCdrCommand({required int days, required int limit}) {
    final pythonCmd = getPythonCommand();
    final scriptPath = config.pythonScriptPath;
    
    return '$pythonCmd $scriptPath cdr --days $days --limit $limit';
  }
  
  /// Adapt recording path based on generation
  String getRecordingPath(DateTime callDate) {
    return config.getRecordingPath(callDate);
  }
  
  /// Get authentication method
  String getAuthMethod() {
    if (config.requiresKeyAuth) {
      return 'publickey';
    }
    return 'password';
  }
}
```

---

### Task 3.3: Create CDR Adapter
**مدت زمان**: 3 ساعت  
**فایل**: `lib/core/adapters/cdr_adapter.dart`

```dart
import '../generation/generation_config.dart';
import '../app_config.dart';

class CdrAdapter {
  final GenerationConfig config;
  
  CdrAdapter(this.config);
  
  factory CdrAdapter.current() => CdrAdapter(AppConfig.current);
  
  /// Parse CDR record with generation-aware logic
  Map<String, dynamic> parseCdrRecord(String line) {
    final parts = line.split(',');
    
    if (parts.length < config.cdrColumnCount) {
      throw FormatException(
        'Invalid CDR record: expected ${config.cdrColumnCount} columns, '
        'got ${parts.length}',
      );
    }
    
    final record = <String, dynamic>{};
    final columns = config.cdrColumns;
    
    for (var i = 0; i < columns.length && i < parts.length; i++) {
      record[columns[i]] = parts[i].replaceAll('"', '');
    }
    
    // Adapt to standard format
    return config.adaptCDRRecord(record);
  }
  
  /// Parse call date with timezone support
  DateTime parseCallDate(String dateStr) {
    if (config.supportsTimezone) {
      return DateTime.parse(dateStr);
    } else {
      // Legacy: No timezone info, assume UTC
      return DateTime.parse(dateStr).toUtc();
    }
  }
}
```

---

## 🎭 PHASE 4: MOCK INFRASTRUCTURE

### Task 4.1: Create Mock Classes
**مدت زمان**: 3 ساعت  
**فایل**: `lib/mocks/mock_classes.dart`

```dart
import 'package:mocktail/mocktail.dart';
import 'package:astrix_assist/core/ssh_service.dart';
import 'package:astrix_assist/data/datasources/ami_datasource.dart';
import 'package:astrix_assist/data/repositories/cdr_repository_impl.dart';
// ... import all interfaces

// SSH Mocks
class MockSshService extends Mock implements SshService {}
class MockSshClient extends Mock implements SSHClient {}
class MockSFTPClient extends Mock implements SftpClient {}

// AMI Mocks
class MockAmiDataSource extends Mock implements AmiDataSource {}
class MockAmiSocket extends Mock implements Socket {}

// Repository Mocks
class MockCdrRepository extends Mock implements CdrRepository {}
class MockExtensionRepository extends Mock implements ExtensionRepository {}
class MockMonitorRepository extends Mock implements MonitorRepository {}

// UseCase Mocks
class MockGetCdrRecordsUseCase extends Mock implements GetCdrRecordsUseCase {}
class MockGetExtensionsUseCase extends Mock implements GetExtensionsUseCase {}
// ... all other usecases

// Generation Mocks
class MockGenerationConfig extends Mock implements GenerationConfig {}
class MockAmiAdapter extends Mock implements AmiAdapter {}
class MockSshAdapter extends Mock implements SshAdapter {}
class MockCdrAdapter extends Mock implements CdrAdapter {}
```

---

### Task 4.2: Create Test Fixtures Generator
**مدت زमان**: 6 ساعت  
**فایل**: `test/fixtures/fixture_generator.dart`

```dart
import 'dart:convert';
import 'dart:io';

/// Generator for test fixtures
class FixtureGenerator {
  static const _baseFixturePath = 'test/fixtures';
  
  /// Generate all fixtures for all generations
  static Future<void> generateAll() async {
    for (var gen = 1; gen <= 4; gen++) {
      await generateForGeneration(gen);
    }
  }
  
  /// Generate fixtures for specific generation
  static Future<void> generateForGeneration(int generation) async {
    final genPath = '$_baseFixturePath/generation_$generation';
    await Directory(genPath).create(recursive: true);
    
    await _generateCdrData(generation, genPath);
    await _generateAmiResponses(generation, genPath);
    await _generateSshOutputs(generation, genPath);
    await _generateExtensionsData(generation, genPath);
    await _generateRecordings(generation, genPath);
  }
  
  static Future<void> _generateCdrData(int gen, String path) async {
    // Generate 100 sample CDR records
    final records = <Map<String, dynamic>>[];
    
    for (var i = 0; i < 100; i++) {
      records.add(_generateCdrRecord(gen, i));
    }
    
    final file = File('$path/cdr_samples.json');
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(records),
    );
  }
  
  static Map<String, dynamic> _generateCdrRecord(int gen, int index) {
    final baseRecord = {
      'accountcode': '',
      'src': '100${index % 10}',
      'dst': '091551190${index % 100}',
      'dcontext': 'from-internal',
      'clid': '"" <100${index % 10}>',
      'channel': 'SIP/100${index % 10}-000000${index.toRadixString(16)}',
      'dstchannel': 'SIP/shatel-trunk-000000${index.toRadixString(16)}',
      'lastapp': 'Dial',
      'lastdata': 'SIP/shatel-trunk/091551190${index % 100},300,T',
      'calldate': DateTime.now()
          .subtract(Duration(hours: index))
          .toIso8601String(),
      'duration': '${20 + (index % 60)}',
      'billsec': '${15 + (index % 50)}',
      'disposition': index % 3 == 0 ? 'ANSWERED' : 'NO ANSWER',
      'amaflags': 'DOCUMENTATION',
    };
    
    // Add generation-specific fields
    if (gen >= 2) {
      baseRecord['uniqueid'] = '${DateTime.now().millisecondsSinceEpoch}.$index';
      baseRecord['userfield'] = '';
      baseRecord['answerdate'] = baseRecord['calldate'];
    }
    
    if (gen >= 3) {
      baseRecord['enddate'] = DateTime.now()
          .subtract(Duration(hours: index - 1))
          .toIso8601String();
      baseRecord['sequence'] = '$index';
    }
    
    if (gen >= 4) {
      baseRecord['linkedid'] = baseRecord['uniqueid'];
      baseRecord['peeraccount'] = '';
    }
    
    return baseRecord;
  }
  
  static Future<void> _generateAmiResponses(int gen, String path) async {
    final responses = {
      'login_success': _generateLoginResponse(gen),
      'sippeers': _generateSIPPeersResponse(gen),
      'queue_status': _generateQueueStatusResponse(gen),
      'status': _generateStatusResponse(gen),
    };
    
    if (gen >= 2) {
      responses['core_show_channels'] = _generateCoreShowChannelsResponse(gen);
    }
    
    if (gen >= 4) {
      responses['pjsip_show_endpoints'] = _generatePJSIPEndpointsResponse(gen);
    }
    
    final file = File('$path/ami_responses.json');
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(responses),
    );
  }
  
  // ... more generator methods
}
```

---

### Task 4.3: Create Mock SSH Server
**مدت زمان**: 8 ساعت  
**فایل**: `tools/mock_servers/mock_ssh_server.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Mock SSH Server for testing
class MockSshServer {
  final int generation;
  final int port;
  late ServerSocket _server;
  bool _isRunning = false;
  
  MockSshServer({
    required this.generation,
    this.port = 2222,
  });
  
  Future<void> start() async {
    _server = await ServerSocket.bind('127.0.0.1', port);
    _isRunning = true;
    
    print('Mock SSH Server (Gen $generation) started on port $port');
    
    _server.listen(_handleConnection);
  }
  
  void _handleConnection(Socket socket) {
    print('Client connected: ${socket.remoteAddress}:${socket.remotePort}');
    
    final session = _SshSession(socket, generation);
    session.start();
  }
  
  Future<void> stop() async {
    _isRunning = false;
    await _server.close();
    print('Mock SSH Server stopped');
  }
}

class _SshSession {
  final Socket socket;
  final int generation;
  bool _authenticated = false;
  
  _SshSession(this.socket, this.generation);
  
  void start() {
    // Send SSH banner
    _sendLine('SSH-2.0-MockSSH_Gen${generation}_1.0');
    
    socket.listen(
      _handleData,
      onDone: () => print('Client disconnected'),
      onError: (error) => print('Error: $error'),
    );
  }
  
  void _handleData(List<int> data) {
    final command = utf8.decode(data).trim();
    
    if (!_authenticated) {
      _handleAuth(command);
      return;
    }
    
    _handleCommand(command);
  }
  
  void _handleAuth(String credentials) {
    // Simple mock authentication
    if (credentials.contains('root') || credentials.contains('admin')) {
      _authenticated = true;
      _sendLine('Authentication successful');
    } else {
      _sendLine('Authentication failed');
      socket.close();
    }
  }
  
  void _handleCommand(String command) {
    if (command.startsWith('python')) {
      _handlePythonCommand(command);
    } else if (command == 'ls /var/spool/asterisk/monitor') {
      _handleListRecordings();
    } else if (command.startsWith('cat ')) {
      _handleCatFile(command);
    } else {
      _sendLine('Command not found: $command');
    }
  }
  
  void _handlePythonCommand(String command) {
    if (command.contains('cdr')) {
      _sendCdrData();
    } else if (command.contains('extensions')) {
      _sendExtensionsData();
    }
  }
  
  void _sendCdrData() {
    // Load fixture data based on generation
    final fixture = File('test/fixtures/generation_$generation/cdr_samples.json');
    if (fixture.existsSync()) {
      final data = fixture.readAsStringSync();
      _sendLine(data);
    }
  }
  
  void _sendLine(String line) {
    socket.write('$line\n');
  }
}
```

---

### Task 4.4: Create Mock AMI Server
**مدت زمان**: 8 ساعت  
**فایل**: `tools/mock_servers/mock_ami_server.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Mock Asterisk Manager Interface (AMI) Server
class MockAmiServer {
  final int generation;
  final int port;
  late ServerSocket _server;
  
  MockAmiServer({
    required this.generation,
    this.port = 5038,
  });
  
  Future<void> start() async {
    _server = await ServerSocket.bind('127.0.0.1', port);
    
    print('Mock AMI Server (Gen $generation) started on port $port');
    
    _server.listen(_handleConnection);
  }
  
  void _handleConnection(Socket socket) {
    print('AMI Client connected');
    
    final session = _AmiSession(socket, generation);
    session.start();
  }
  
  Future<void> stop() async {
    await _server.close();
  }
}

class _AmiSession {
  final Socket socket;
  final int generation;
  bool _authenticated = false;
  
  _AmiSession(this.socket, this.generation);
  
  void start() {
    // Send AMI greeting
    _send({
      'Response': 'Success',
      'Message': 'Asterisk Call Manager/${_getAmiVersion()}',
    });
    
    socket.listen(
      _handleData,
      onDone: () => print('AMI Client disconnected'),
    );
  }
  
  String _getAmiVersion() {
    switch (generation) {
      case 1:
        return '1.1';
      case 2:
        return '2.0';
      case 3:
        return '2.5';
      case 4:
        return '3.0';
      default:
        return '1.0';
    }
  }
  
  void _handleData(List<int> data) {
    final text = utf8.decode(data);
    final message = _parseAmiMessage(text);
    
    if (message['Action'] == 'Login') {
      _handleLogin(message);
    } else if (!_authenticated) {
      _sendError('Not authenticated');
      return;
    }
    
    _handleAction(message);
  }
  
  void _handleAction(Map<String, String> message) {
    final action = message['Action'];
    
    switch (action) {
      case 'SIPpeers':
        _sendSIPPeers();
        break;
      case 'QueueStatus':
        _sendQueueStatus();
        break;
      case 'Status':
        _sendStatus();
        break;
      case 'CoreShowChannels':
        if (generation >= 2) {
          _sendCoreShowChannels();
        } else {
          _sendError('Command not available in this version');
        }
        break;
      default:
        _sendError('Unknown action: $action');
    }
  }
  
  void _sendSIPPeers() {
    // Load fixture
    final fixture = File('test/fixtures/generation_$generation/ami_responses.json');
    if (fixture.existsSync()) {
      final data = json.decode(fixture.readAsStringSync());
      _send(data['sippeers']);
    }
  }
  
  void _send(Map<String, dynamic> message) {
    final buffer = StringBuffer();
    message.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    buffer.writeln(''); // Empty line to end message
    
    socket.write(buffer.toString());
  }
  
  Map<String, String> _parseAmiMessage(String text) {
    final lines = text.split('\n');
    final message = <String, String>{};
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      final parts = line.split(':');
      if (parts.length >= 2) {
        message[parts[0].trim()] = parts.sublist(1).join(':').trim();
      }
    }
    
    return message;
  }
}
```

---

## 🧪 PHASE 5: UNIT TESTS

### Task 5.1: Test Generation Configs
**مدت زمان**: 4 ساعت  
**فایل**: `test/unit/core/generation/generation_config_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/generation/generation_1_config.dart';
import 'package:astrix_assist/core/generation/generation_2_config.dart';
import 'package:astrix_assist/core/generation/generation_3_config.dart';
import 'package:astrix_assist/core/generation/generation_4_config.dart';

void main() {
  group('Generation Configs', () {
    test('Generation 1 has correct properties', () {
      final config = Generation1Config();
      
      expect(config.generation, 1);
      expect(config.name, 'Legacy');
      expect(config.osName, 'CentOS');
      expect(config.osVersion, '6.x');
      expect(config.asteriskVersion, '11.x');
      expect(config.pythonVersion, '2.6');
      expect(config.cdrColumnCount, 14);
      expect(config.supportsCoreShowChannels, false);
      expect(config.supportsPJSIP, false);
    });
    
    test('Generation 4 has all modern features', () {
      final config = Generation4Config();
      
      expect(config.generation, 4);
      expect(config.supportsCoreShowChannels, true);
      expect(config.supportsPJSIP, true);
      expect(config.supportsJSON, true);
      expect(config.supportsCEL, true);
      expect(config.cdrColumnCount, greaterThan(19));
    });
    
    test('Recording paths are generation-specific', () {
      final date = DateTime(2025, 12, 23);
      
      final gen1 = Generation1Config();
      final gen2 = Generation2Config();
      
      // Gen 1: No date subdirectories
      expect(
        gen1.getRecordingPath(date),
        '/var/spool/asterisk/monitor',
      );
      
      // Gen 2+: Date subdirectories
      expect(
        gen2.getRecordingPath(date),
        '/var/spool/asterisk/monitor/2025/12/23',
      );
    });
    
    test('AMI command adaptation works', () {
      final gen1 = Generation1Config();
      
      // CoreShowChannels not supported in Gen 1
      expect(
        gen1.adaptAMICommand('CoreShowChannels'),
        'Status',
      );
      
      // Other commands pass through
      expect(
        gen1.adaptAMICommand('SIPpeers'),
        'SIPpeers',
      );
    });
  });
}
```

---

### Task 5.2: Test AppConfig
**مدت زمان**: 2 ساعت  
**فایل**: `test/unit/core/app_config_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  group('AppConfig', () {
    tearDown(() {
      AppConfig.resetGeneration();
    });
    
    test('default generation is 4', () {
      expect(AppConfig.current.generation, 4);
    });
    
    test('can set generation at runtime', () {
      AppConfig.setGeneration(1);
      expect(AppConfig.current.generation, 1);
      
      AppConfig.setGeneration(2);
      expect(AppConfig.current.generation, 2);
    });
    
    test('throws error for invalid generation', () {
      expect(
        () => AppConfig.setGeneration(0),
        throwsArgumentError,
      );
      
      expect(
        () => AppConfig.setGeneration(5),
        throwsArgumentError,
      );
    });
    
    test('reset returns to default', () {
      AppConfig.setGeneration(1);
      expect(AppConfig.current.generation, 1);
      
      AppConfig.resetGeneration();
      expect(AppConfig.current.generation, 4);
    });
  });
}
```

---

### Task 5.3: Test Adapters
**مدت زمان**: 6 ساعت  
**فایل‌ها**:
- `test/unit/core/adapters/ami_adapter_test.dart`
- `test/unit/core/adapters/ssh_adapter_test.dart`
- `test/unit/core/adapters/cdr_adapter_test.dart`

**نمونه**: `cdr_adapter_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/adapters/cdr_adapter.dart';
import 'package:astrix_assist/core/generation/generation_1_config.dart';
import 'package:astrix_assist/core/generation/generation_4_config.dart';

void main() {
  group('CdrAdapter', () {
    test('parses Generation 1 CDR record (14 columns)', () {
      final adapter = CdrAdapter(Generation1Config());
      
      const line = '"",'
          '"1003","09155119004","from-internal","",'
          '"SIP/1003-000000c6","SIP/shatel-trunk-000000c7",'
          '"Dial","SIP/shatel-trunk/09155119004,300,T",'
          '"2025-12-23 12:41:27","29","23","ANSWERED","DOCUMENTATION"';
      
      final record = adapter.parseCdrRecord(line);
      
      expect(record['src'], '1003');
      expect(record['dst'], '09155119004');
      expect(record['duration'], '29');
      expect(record['disposition'], 'ANSWERED');
    });
    
    test('parses Generation 4 CDR record (20+ columns)', () {
      final adapter = CdrAdapter(Generation4Config());
      
      // Include all 20+ columns
      const line = '"",'
          '"1003","09155119004","from-internal","",'
          '"SIP/1003-000000c6","SIP/shatel-trunk-000000c7",'
          '"Dial","SIP/shatel-trunk/09155119004,300,T",'
          '"2025-12-23 12:41:27",'
          '"2025-12-23 12:41:33",'
          '"2025-12-23 12:41:56",'
          '"29","23","ANSWERED","DOCUMENTATION",'
          '"1766493687.1420","",'
          '"1766493687.1420","",'
          '"100"';
      
      final record = adapter.parseCdrRecord(line);
      
      expect(record['uniqueid'], '1766493687.1420');
      expect(record['linkedid'], '1766493687.1420');
    });
    
    test('adapts CDR record for compatibility', () {
      final adapter = CdrAdapter(Generation1Config());
      
      final input = {
        'src': '1003',
        'dst': '09155119004',
      };
      
      final adapted = adapter.parseCdrRecord('"",...'); // Simplified
      
      // Should add missing fields
      expect(adapted.containsKey('uniqueid'), true);
      expect(adapted.containsKey('answerdate'), true);
    });
  });
}
```

---

### Task 5.4: Complete Existing Unit Tests
**مدت زمان**: 8 ساعت  

**وظایف**:
1. بررسی تست‌های موجود در `test/`
2. افزودن تست‌های گمشده
3. بهبود coverage به 80%+
4. اضافه کردن edge cases
5. تست‌های error handling

---

## 🎨 PHASE 6: WIDGET TESTS

### Task 6.1: Test CDR Page
**مدت زمان**: 4 ساعت  
**فایل**: `test/widget/presentation/pages/cdr_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:astrix_assist/presentation/pages/cdr_page.dart';
import 'package:astrix_assist/presentation/blocs/cdr_bloc.dart';
import '../../../mocks/test_mocks.dart';

void main() {
  late MockCdrBloc mockCdrBloc;
  
  setUp(() {
    mockCdrBloc = MockCdrBloc();
    when(() => mockCdrBloc.stream).thenAnswer((_) => const Stream.empty());
  });
  
  Widget buildWidget(CdrState state) {
    when(() => mockCdrBloc.state).thenReturn(state);
    
    return MaterialApp(
      home: BlocProvider<CdrBloc>.value(
        value: mockCdrBloc,
        child: const CdrPage(),
      ),
    );
  }
  
  group('CdrPage Widget Tests', () {
    testWidgets('displays loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildWidget(const CdrLoading()));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('displays CDR records when loaded', (tester) async {
      final records = [
        // Test data
      ];
      
      await tester.pumpWidget(buildWidget(CdrLoaded(records: records)));
      await tester.pumpAndSettle();
      
      expect(find.text('1003'), findsWidgets);
      expect(find.text('09155119004'), findsWidgets);
    });
    
    testWidgets('play button works', (tester) async {
      // Test play button functionality
    });
  });
}
```

---

### Task 6.2: Test Other Pages
**مدت زمان**: 8 ساعت  

**فایل‌ها**:
- `test/widget/presentation/pages/extensions_page_test.dart`
- `test/widget/presentation/pages/queue_page_test.dart`
- `test/widget/presentation/pages/active_calls_page_test.dart`
- `test/widget/presentation/pages/dashboard_page_test.dart`

---

## 🔗 PHASE 7: INTEGRATION TESTS

### Task 7.1: Generation Switching Test
**مدت زمان**: 3 ساعت  
**فایل**: `test/integration/generation_switching_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  group('Generation Switching Integration', () {
    setUp(() {
      AppConfig.resetGeneration();
    });
    
    test('can switch between all generations', () {
      for (var gen = 1; gen <= 4; gen++) {
        AppConfig.setGeneration(gen);
        
        final config = AppConfig.current;
        expect(config.generation, gen);
        
        // Verify generation-specific features
        if (gen == 1) {
          expect(config.supportsCoreShowChannels, false);
        } else {
          expect(config.supportsCoreShowChannels, true);
        }
      }
    });
    
    test('config properties change with generation', () {
      AppConfig.setGeneration(1);
      final gen1CDRColumns = AppConfig.current.cdrColumnCount;
      
      AppConfig.setGeneration(4);
      final gen4CDRColumns = AppConfig.current.cdrColumnCount;
      
      expect(gen4CDRColumns, greaterThan(gen1CDRColumns));
    });
  });
}
```

---

### Task 7.2: Mock Server Integration Tests
**مدت زمان**: 6 ساعت  
**فایل**: `test/integration/mock_server_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/ssh_service.dart';
import '../../tools/mock_servers/mock_ssh_server.dart';
import '../../tools/mock_servers/mock_ami_server.dart';

void main() {
  group('Mock Server Integration', () {
    late MockSshServer sshServer;
    late MockAmiServer amiServer;
    
    setUpAll(() async {
      sshServer = MockSshServer(generation: 4, port: 2222);
      amiServer = MockAmiServer(generation: 4, port: 15038);
      
      await sshServer.start();
      await amiServer.start();
    });
    
    tearDownAll(() async {
      await sshServer.stop();
      await amiServer.stop();
    });
    
    test('can connect to mock SSH server', () async {
      final sshService = SshService();
      
      await sshService.connect(
        host: '127.0.0.1',
        port: 2222,
        username: 'root',
        password: 'test',
      );
      
      expect(sshService.isConnected, true);
    });
    
    test('can execute commands on mock SSH', () async {
      final sshService = SshService();
      await sshService.connect(
        host: '127.0.0.1',
        port: 2222,
        username: 'root',
        password: 'test',
      );
      
      final result = await sshService.execute('python cdr --days 7 --limit 100');
      
      expect(result, isNotNull);
      expect(result, contains('success'));
    });
  });
}
```

---

### Task 7.3: End-to-End Feature Tests
**مدت زمان**: 8 ساعت  
**فایل**: `test/integration/e2e_feature_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';
// Import all necessary classes

void main() {
  group('End-to-End Feature Tests', () {
    for (var gen = 1; gen <= 4; gen++) {
      group('Generation $gen', () {
        setUp(() {
          AppConfig.setGeneration(gen);
        });
        
        test('CDR fetching works', () async {
          // Test CDR fetching for this generation
        });
        
        test('Extensions listing works', () async {
          // Test extensions
        });
        
        test('Recording playback works', () async {
          // Test recordings (if supported)
        });
      });
    }
  });
}
```

---

## 📦 PHASE 8: DOCUMENTATION & CLEANUP

### Task 8.1: Write API Documentation
**مدت زمان**: 4 ساعت  

**فایل‌ها**:
- `docs/api/generation_config_api.md`
- `docs/api/adapter_api.md`
- `docs/api/mock_server_api.md`

---

### Task 8.2: Write User Guide
**مدت زمان**: 3 ساعت  
**فایل**: `docs/GENERATION_USER_GUIDE.md`

```markdown
# Generation System User Guide

## How to Change Generation

### At Compile Time (Production)
Edit `lib/core/app_config.dart`:

```dart
static const int defaultGeneration = 4; // Change this
```

### At Runtime (Testing Only)
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

## Running Tests for Specific Generation

```bash
# Test all generations
flutter test

# Test specific generation (via environment variable)
flutter test --dart-define=TEST_GENERATION=1
```

## Using Mock Servers

```bash
# Start mock servers
dart tools/mock_servers/run_mock_servers.dart --generation=2

# In another terminal
flutter test test/integration/
```
```

---

### Task 8.3: Create Migration Guide
**مدت زمان**: 2 ساعت  
**فایل**: `docs/MIGRATION_GUIDE.md`

---

### Task 8.4: Update README
**مدت زمان**: 1 ساعت  
**فایل**: `README.md`

Add section about generation support.

---

## ✅ PHASE 9: VERIFICATION & VALIDATION

### Task 9.1: Run All Tests
**مدت زمان**: 2 ساعت  

```bash
# Run all tests
flutter test

# Check coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Target Coverage**:
- Unit Tests: 80%+
- Widget Tests: 70%+
- Integration Tests: 60%+

---

### Task 9.2: Verify Mock Servers
**مدت زمان**: 2 ساعت  

**چک‌لیست**:
- [ ] Mock SSH Server راه‌اندازی می‌شود
- [ ] Mock AMI Server راه‌اندازی می‌شود
- [ ] همه دستورات شبیه‌سازی می‌شوند
- [ ] Fixtures به درستی بارگذاری می‌شوند
- [ ] Error handling کار می‌کند

---

### Task 9.3: Test on Real Device
**مدت زمان**: 3 ساعت  

**دستگاه تست**: SM X216B (R92Y704M3XT)

**سناریوها**:
1. نصب app با Generation 1
2. تست تمام features
3. تغییر به Generation 4
4. تست مجدد
5. بررسی performance

---

### Task 9.4: Code Review Checklist
**مدت زمان**: 2 ساعت  

**چک‌لیست**:
- [ ] همه فایل‌ها documentation دارند
- [ ] همه متدها type-safe هستند
- [ ] Error handling کامل است
- [ ] Logging مناسب اضافه شده
- [ ] Code style یکسان است
- [ ] No hardcoded values
- [ ] All TODOs addressed

---

## 📈 SUCCESS METRICS

### Code Quality
- [ ] Test Coverage > 75%
- [ ] No critical Linter warnings
- [ ] All tests passing
- [ ] Documentation complete

### Functionality
- [ ] All 4 generations working
- [ ] Mock servers operational
- [ ] Adapters functioning correctly
- [ ] Runtime switching works

### Performance
- [ ] App startup < 3 seconds
- [ ] Test suite runs < 5 minutes
- [ ] Mock servers responsive < 100ms
- [ ] No memory leaks

---

## 🚀 DEPLOYMENT CHECKLIST

### Before Merge
- [ ] All tests pass
- [ ] Coverage meets targets
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] No merge conflicts

### After Merge
- [ ] Tag release
- [ ] Update CHANGELOG
- [ ] Notify team
- [ ] Monitor for issues

---

## 📝 NOTES FOR GROK AI

### Important Guidelines

1. **Research First**: Always check official documentation before implementing
2. **Test Coverage**: Aim for high coverage, don't skip tests
3. **Code Quality**: Follow Dart/Flutter best practices
4. **Documentation**: Document every public API
5. **Error Handling**: Never leave try-catch empty
6. **Logging**: Use proper logging levels
7. **Performance**: Profile before optimizing
8. **Security**: Never hardcode credentials

### Common Pitfalls to Avoid

1. ❌ Guessing API behavior → ✅ Check documentation
2. ❌ Skipping edge cases → ✅ Test boundary conditions
3. ❌ Incomplete error handling → ✅ Handle all error cases
4. ❌ Hardcoded test data → ✅ Use fixtures
5. ❌ Ignoring async issues → ✅ Proper async/await

### Testing Best Practices

1. **AAA Pattern**: Arrange, Act, Assert
2. **One assertion per test** (when possible)
3. **Descriptive test names**
4. **Setup/Teardown properly**
5. **Mock external dependencies**
6. **Test both success and failure paths**

### File Naming Conventions

```
lib/
  feature_name/
    feature_name.dart
    feature_name_impl.dart
    
test/
  unit/
    feature_name/
      feature_name_test.dart
  widget/
    feature_name/
      feature_name_widget_test.dart
  integration/
    feature_name_integration_test.dart
```

---

## 🆘 TROUBLESHOOTING

### If Tests Fail

1. Check if dependencies are installed: `flutter pub get`
2. Clear build cache: `flutter clean`
3. Regenerate mocks: `flutter pub run build_runner build --delete-conflicting-outputs`
4. Check Flutter version: `flutter doctor`

### If Mock Servers Don't Start

1. Check if port is available: `netstat -an | findstr :2222`
2. Check firewall settings
3. Verify fixture files exist
4. Check logs for errors

### If Coverage is Low

1. Identify uncovered code: `genhtml coverage/lcov.info`
2. Add missing unit tests first
3. Then widget tests
4. Finally integration tests

---

## 📞 CONTACT & SUPPORT

**Project Owner**: Moein  
**Project**: Astrix Assist  
**Repository**: C:\Users\Moein\Documents\Codes\astrix_assist

For questions or issues during implementation, please:
1. Check this document first
2. Review existing code in mik_flutter project
3. Consult official documentation
4. Ask for clarification if needed

---

## ✨ FINAL DELIVERABLES

When complete, you should have:

1. ✅ 4 Generation Config classes
2. ✅ 3 Adapter classes
3. ✅ 2 Mock Server implementations
4. ✅ 100+ test files
5. ✅ Complete fixture data for 4 generations
6. ✅ Comprehensive documentation
7. ✅ 75%+ test coverage
8. ✅ All features working for all generations

**Estimated Total Time**: 80-100 hours (2-3 weeks full-time)

---

## 🎓 LEARNING RESOURCES

### Asterisk Documentation
- https://docs.asterisk.org/
- https://wiki.asterisk.org/

### Flutter Testing
- https://docs.flutter.dev/testing
- https://pub.dev/packages/mocktail
- https://pub.dev/packages/bloc_test

### Best Practices
- Clean Architecture in Flutter
- Test-Driven Development (TDD)
- SOLID Principles

---

**Good luck with the implementation! 🚀**

*This plan was created on December 23, 2025*
