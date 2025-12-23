import 'generation_config.dart';

/// Generation 1 Configuration: CentOS 6 + Asterisk 11 (Legacy)
///
/// Timeline: 2012-2015
/// AMI Version: 1.1
/// CDR Columns: 14
/// Features: Basic AMI, No CoreShowChannels, No PJSIP
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
  String get pythonScriptPath => '/usr/local/bin/astrix_cdr.py';

  @override
  List<String> get supportedAmiCommands => [
    'Login',
    'Logoff',
    'SIPpeers',
    'SIPshowpeer',
    'QueueStatus',
    'Status',
    'Command',
    'CoreSettings',
    'CoreStatus',
  ];

  @override
  List<String> get supportedRecordingFormats => [
    'wav',
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
  int get defaultSSHPort => 22;

  @override
  bool get requiresKeyAuth => false;

  @override
  bool get supports2FA => false;

  @override
  int get defaultAMIPort => 5038;

  @override
  String get amiVersion => '1.1';

  @override
  String getPythonCommand() => 'python2.6';

  @override
  Map<String, String> getPythonScriptArgs() => {
    'cdr_command': 'cdr',
    'days_param': '--days',
    'limit_param': '--limit',
  };

  @override
  String adaptAMICommand(String command) {
    // Asterisk 11 doesn't support CoreShowChannels
    if (command == 'CoreShowChannels') {
      return 'Status'; // Fallback to Status
    }
    return command;
  }

  @override
  Map<String, dynamic> adaptAMIResponse(
    String command,
    Map<String, dynamic> response,
  ) {
    // Generation 1 responses are text-based, no adaptation needed
    return response;
  }

  @override
  String get pythonPath => '/usr/bin/python2.6';

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
  ];

  @override
  List<String> get systemPaths => [
    '/usr/bin',
    '/usr/local/bin',
    '/bin',
  ];

  @override
  String adaptSSHCommand(String command) {
    // Python 2.6 compatibility
    if (command.contains('python3') || command.contains('python')) {
      return command.replaceAll(RegExp(r'python3?\s'), 'python2.6 ');
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
    // Generation 1: Basic adaptation, add missing fields
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