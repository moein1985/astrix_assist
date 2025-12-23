import 'generation_config.dart';

/// Generation 2 Configuration: CentOS 7 + Asterisk 13 (Transition)
///
/// Timeline: 2015-2018
/// AMI Version: 2.0
/// CDR Columns: 17
/// Features: CoreShowChannels, Basic PJSIP, Enhanced CDR
class Generation2Config implements GenerationConfig {
  @override
  int get generation => 2;

  @override
  String get name => 'Transition';

  @override
  String get description => 'CentOS 7 + Asterisk 13 (2015-2018)';

  @override
  String get osName => 'CentOS';

  @override
  String get osVersion => '7.x';

  @override
  String get asteriskVersion => '13.x';

  @override
  String get pythonVersion => '2.7';

  @override
  String get cdrFilePath => '/var/log/asterisk/cdr-csv/Master.csv';

  @override
  String get recordingBasePath => '/var/spool/asterisk/monitor';

  @override
  String getRecordingPath(DateTime callDate) {
    // Generation 2: Date-based subdirectories
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
    'QueueStatus',
    'QueueSummary',
    'QueueAdd',
    'QueueRemove',
    'Status',
    'CoreShowChannels', // New in Gen 2
    'CoreSettings',
    'CoreStatus',
    'MeetmeList',
    'Command',
  ];

  @override
  List<String> get supportedRecordingFormats => [
    'wav',
    'gsm',
  ];

  @override
  bool get supportsCoreShowChannels => true;

  @override
  bool get supportsPJSIP => true; // Basic support

  @override
  bool get supportsJSON => false;

  @override
  bool get supportsCEL => false;

  @override
  int get cdrColumnCount => 17;

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
    'uniqueid', // New in Gen 2
    'userfield', // New in Gen 2
    'answerdate', // New in Gen 2
  ];

  @override
  bool get supportsTimezone => false; // Still no timezone in CDR

  @override
  String get defaultTimezone => 'UTC';

  @override
  List<String> get supportedAuthMethods => ['password', 'publickey'];

  @override
  int get defaultSSHPort => 22;

  @override
  bool get requiresKeyAuth => false; // Optional

  @override
  bool get supports2FA => false;

  @override
  int get defaultAMIPort => 5038;

  @override
  String get amiVersion => '2.0';

  @override
  String getPythonCommand() => 'python2.7';

  @override
  Map<String, String> getPythonScriptArgs() => {
    'cdr_command': 'cdr',
    'days_param': '--days',
    'limit_param': '--limit',
  };

  @override
  String adaptAMICommand(String command) {
    // Generation 2 supports most commands natively
    return command;
  }

  @override
  Map<String, dynamic> adaptAMIResponse(
    String command,
    Map<String, dynamic> response,
  ) {
    // Basic adaptation for CoreShowChannels vs Status differences
    if (command == 'Status' && supportsCoreShowChannels) {
      // Could adapt Status response to CoreShowChannels format
      // For now, return as-is
    }
    return response;
  }

  @override
  String get pythonPath => '/usr/bin/python2.7';

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
    'json', // Python 2.7 has json module
  ];

  @override
  List<String> get systemPaths => [
    '/usr/bin',
    '/usr/local/bin',
    '/bin',
  ];

  @override
  String adaptSSHCommand(String command) {
    // Python 2.7 compatibility
    if (command.contains('python3')) {
      return command.replaceAll('python3', 'python2.7');
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
  Map<String, dynamic> adaptCDRRecord(Map<String, dynamic> record) {
    // Generation 2: Basic adaptation, add missing fields
    return {
      ...record,
      'linkedid': record['linkedid'] ?? record['uniqueid'] ?? '',
      'peeraccount': record['peeraccount'] ?? '',
    };
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