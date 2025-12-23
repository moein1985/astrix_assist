import 'generation_config.dart';

/// Generation 3 Configuration: Rocky Linux 8 + Asterisk 16 (Modern)
///
/// Timeline: 2018-2022
/// AMI Version: 2.5
/// CDR Columns: 19
/// Features: Full PJSIP, JSON support, Timezone
class Generation3Config implements GenerationConfig {
  @override
  int get generation => 3;

  @override
  String get name => 'Modern';

  @override
  String get description => 'Rocky Linux 8 + Asterisk 16 (2018-2022)';

  @override
  String get osName => 'Rocky Linux';

  @override
  String get osVersion => '8.x';

  @override
  String get asteriskVersion => '16.x';

  @override
  String get pythonVersion => '3.6';

  @override
  String get cdrFilePath => '/var/log/asterisk/cdr-csv/Master.csv';

  @override
  String get recordingBasePath => '/var/spool/asterisk/monitor';

  @override
  String getRecordingPath(DateTime callDate) {
    // Generation 3: Date-based subdirectories (same as Gen 2)
    final year = callDate.year.toString();
    final month = callDate.month.toString().padLeft(2, '0');
    final day = callDate.day.toString().padLeft(2, '0');
    return '$recordingBasePath/$year/$month/$day';
  }

  @override
  String get pythonScriptPath => '/usr/local/bin/astrix_cdr.py';

  @override
  List<String> get supportedAmiCommands => [
    'Login',
    'Logoff',
    'SIPpeers',
    'SIPshowpeer',
    'PJSIPShowEndpoints', // New in Gen 3
    'PJSIPShowEndpoint', // New in Gen 3
    'PJSIPShowContacts', // New in Gen 3
    'QueueStatus',
    'QueueSummary',
    'QueueAdd',
    'QueueRemove',
    'QueueLog', // New in Gen 3
    'Status',
    'CoreShowChannels',
    'CoreSettings',
    'CoreStatus',
    'MeetmeList',
    'ConfbridgeList',
    'Command',
  ];

  @override
  List<String> get supportedRecordingFormats => [
    'wav',
    'gsm',
    'mp3',
  ];

  @override
  bool get supportsCoreShowChannels => true;

  @override
  bool get supportsPJSIP => true; // Full support

  @override
  bool get supportsJSON => true; // JSON responses available

  @override
  bool get supportsCEL => false; // CEL available but not default

  @override
  int get cdrColumnCount => 19;

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
    'uniqueid',
    'userfield',
    'answerdate',
    'enddate', // New in Gen 3
    'sequence', // New in Gen 3
  ];

  @override
  bool get supportsTimezone => true; // Timezone support added

  @override
  String get defaultTimezone => 'UTC';

  @override
  List<String> get supportedAuthMethods => ['publickey', 'password'];

  @override
  int get defaultSSHPort => 22;

  @override
  bool get requiresKeyAuth => true; // Key auth preferred

  @override
  bool get supports2FA => false;

  @override
  int get defaultAMIPort => 5038;

  @override
  String get amiVersion => '2.5';

  @override
  String getPythonCommand() => 'python3.6';

  @override
  Map<String, String> getPythonScriptArgs() => {
    'cdr_command': 'cdr',
    'days_param': '--days',
    'limit_param': '--limit',
  };

  @override
  String adaptAMICommand(String command) {
    // Generation 3 supports all commands natively
    return command;
  }

  @override
  Map<String, dynamic> adaptAMIResponse(
    String command,
    Map<String, dynamic> response,
  ) {
    // Handle JSON responses if available
    // For now, return as-is (assuming text format)
    return response;
  }

  @override
  Map<String, dynamic> adaptCDRRecord(Map<String, dynamic> record) {
    // Add missing fields for compatibility with Gen 4
    return {
      ...record,
      'linkedid': record['linkedid'] ?? record['uniqueid'] ?? '',
      'peeraccount': record['peeraccount'] ?? '',
    };
  }

  @override
  String get pythonPath => '/usr/bin/python3.6';

  @override
  List<String> get sshOptions => [
    '-o StrictHostKeyChecking=no',
    '-o UserKnownHostsFile=/dev/null',
  ];

  @override
  List<String> get supportedPythonFeatures => [
    'basic',
    'csv',
    'subprocess',
    'json',
    'pathlib',
  ];

  @override
  List<String> get systemPaths => [
    '/usr/bin',
    '/usr/local/bin',
    '/bin',
  ];

  @override
  String adaptSSHCommand(String command) {
    // Python 3.6 compatibility
    if (command.contains('python3') || command.contains('python')) {
      return command.replaceAll(RegExp(r'python3?\s'), 'python3.6 ');
    }
    return command;
  }

  @override
  Map<String, dynamic> parseAMIResponse(String response) {
    final lines = response.split('\r\n');
    final result = <String, dynamic>{};

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          result[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    return result;
  }

  @override
  String getAMILoginCommand(String username, String password) {
    return 'Action: Login\r\nUsername: $username\r\nSecret: $password\r\n\r\n';
  }

  @override
  String getAMILogoutCommand() {
    return 'Action: Logoff\r\n\r\n';
  }

  @override
  bool isAMISuccessResponse(String response) {
    return response.contains('Response: Success');
  }

  @override
  Map<String, dynamic> parseCDR(String cdrLine) {
    final values = cdrLine.replaceAll('"', '').split(',');
    final columns = cdrColumns;

    if (values.length != columns.length) {
      throw FormatException('CDR line has ${values.length} values but expected ${columns.length}');
    }

    final result = <String, dynamic>{};
    for (int i = 0; i < columns.length; i++) {
      result[columns[i]] = values[i].trim();
    }

    return result;
  }

  @override
  String formatCDR(Map<String, dynamic> cdrData) {
    final values = cdrColumns.map((col) => cdrData[col] ?? '').toList();
    return '"${values.join('","')}"';
  }

  @override
  bool isCommandSupported(String command) {
    return supportedAmiCommands.contains(command);
  }

  @override
  bool isFeatureSupported(String feature) {
    switch (feature) {
      case 'core_show_channels':
        return supportsCoreShowChannels;
      case 'pjsip':
        return supportsPJSIP;
      case 'json':
        return supportsJSON;
      case 'cel':
        return supportsCEL;
      case 'timezone':
        return supportsTimezone;
      case 'ssh_2fa':
        return supports2FA;
      default:
        return false;
    }
  }
}