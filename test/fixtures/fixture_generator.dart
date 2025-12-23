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
      'clid': '"John Doe <100${index % 10}>"',
      'channel': 'SIP/100${index % 10}-000000${index.toRadixString(16).padLeft(6, '0')}',
      'dstchannel': 'SIP/trunk-000000${index.toRadixString(16).padLeft(6, '0')}',
      'lastapp': 'Dial',
      'lastdata': 'SIP/trunk/091551190${index % 100},300,T',
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
      final uniqueid = '${DateTime.now().millisecondsSinceEpoch}.$index';
      baseRecord['uniqueid'] = uniqueid;
      baseRecord['userfield'] = '';
      baseRecord['answerdate'] = baseRecord['calldate'] as String;
    }

    if (gen >= 3) {
      baseRecord['enddate'] = DateTime.now()
          .subtract(Duration(hours: index - 1))
          .toIso8601String();
      baseRecord['sequence'] = '$index';
    }

    if (gen >= 4) {
      baseRecord['linkedid'] = baseRecord['uniqueid'] as String;
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

  static Map<String, dynamic> _generateLoginResponse(int gen) {
    return {
      'Response': 'Success',
      'Message': 'Authentication accepted',
      'ActionID': '12345',
    };
  }

  static Map<String, dynamic> _generateSIPPeersResponse(int gen) {
    final peers = <Map<String, dynamic>>[];

    for (var i = 100; i < 110; i++) {
      peers.add({
        'Event': 'PeerEntry',
        'Channeltype': 'SIP',
        'ObjectName': '$i',
        'ChanObjectType': 'peer',
        'IPaddress': '192.168.1.$i',
        'IPport': '5060',
        'Dynamic': 'yes',
        'Natsupport': 'yes',
        'VideoSupport': 'yes',
        'TextSupport': 'yes',
        'ACL': 'no',
        'Status': 'OK (23 ms)',
        'RealtimeDevice': 'no',
      });
    }

    peers.add({
      'Event': 'PeerlistComplete',
      'EventList': 'Complete',
      'ListItems': '${peers.length - 1}',
    });

    return {
      'response': peers,
      'event_count': peers.length,
    };
  }

  static Map<String, dynamic> _generateQueueStatusResponse(int gen) {
    return {
      'Response': 'Success',
      'Event': 'QueueParams',
      'Queue': 'support',
      'Max': '0',
      'Strategy': 'ringall',
      'Calls': '2',
      'Holdtime': '15',
      'TalkTime': '45',
      'Completed': '12',
      'Abandoned': '3',
      'ServiceLevel': '30',
      'ServicelevelPerf': '85.7',
      'Weight': '0',
    };
  }

  static Map<String, dynamic> _generateStatusResponse(int gen) {
    final channels = <Map<String, dynamic>>[];

    for (var i = 0; i < 5; i++) {
      channels.add({
        'Event': 'Status',
        'Privilege': 'Call',
        'Channel': 'SIP/100$i-000000${i.toRadixString(16)}',
        'CallerIDNum': '100$i',
        'CallerIDName': 'Test User $i',
        'ConnectedLineNum': '091551190$i',
        'ConnectedLineName': 'External Call',
        'State': 'Up',
        'Context': 'from-internal',
        'Extension': '091551190$i',
        'Priority': '1',
        'Seconds': '${10 + i * 5}',
        'Link': 'SIP/trunk-000000${i.toRadixString(16)}',
        'Uniqueid': '${DateTime.now().millisecondsSinceEpoch}.$i',
      });
    }

    channels.add({
      'Event': 'StatusComplete',
      'Items': '${channels.length}',
    });

    return {
      'response': channels,
      'channel_count': channels.length - 1,
    };
  }

  static Map<String, dynamic> _generateCoreShowChannelsResponse(int gen) {
    final channels = <Map<String, dynamic>>[];

    for (var i = 0; i < 3; i++) {
      channels.add({
        'Event': 'CoreShowChannel',
        'ActionID': '12345',
        'Channel': 'SIP/100$i-000000${i.toRadixString(16)}',
        'ChannelState': '6',
        'ChannelStateDesc': 'Up',
        'CallerIDNum': '100$i',
        'CallerIDName': 'Test User $i',
        'ConnectedLineNum': '091551190$i',
        'ConnectedLineName': 'External Call',
        'Language': 'en',
        'AccountCode': '',
        'Context': 'from-internal',
        'Exten': '091551190$i',
        'Priority': '1',
        'Uniqueid': '${DateTime.now().millisecondsSinceEpoch}.$i',
        'Linkedid': '${DateTime.now().millisecondsSinceEpoch}.$i',
        'Application': 'Dial',
        'ApplicationData': 'SIP/trunk/091551190$i,300,T',
        'Duration': '00:00:${10 + i * 5}',
        'BridgeId': 'bridge_${i}',
      });
    }

    channels.add({
      'Event': 'CoreShowChannelsComplete',
      'EventList': 'Complete',
      'ActionID': '12345',
      'ListItems': '${channels.length - 1}',
    });

    return {
      'response': channels,
      'active_channels': channels.length - 1,
    };
  }

  static Map<String, dynamic> _generatePJSIPEndpointsResponse(int gen) {
    final endpoints = <Map<String, dynamic>>[];

    for (var i = 200; i < 210; i++) {
      endpoints.add({
        'Event': 'EndpointList',
        'ObjectType': 'endpoint',
        'ObjectName': '$i',
        'Transport': 'transport-udp',
        'Aor': '$i',
        'Auths': 'auth$i',
        'OutboundAuths': '',
        'Contacts': 'contact$i',
        'DeviceState': 'Unavailable',
        'ActiveChannels': '0',
      });
    }

    endpoints.add({
      'Event': 'EndpointListComplete',
      'EventList': 'Complete',
      'ListItems': '${endpoints.length - 1}',
    });

    return {
      'response': endpoints,
      'endpoint_count': endpoints.length - 1,
    };
  }

  static Future<void> _generateSshOutputs(int gen, String path) async {
    final outputs = {
      'python_version': _getPythonVersion(gen),
      'cdr_script_output': _generateCdrScriptOutput(gen),
      'extensions_output': _generateExtensionsOutput(gen),
      'recordings_list': _generateRecordingsList(gen),
    };

    final file = File('$path/ssh_outputs.json');
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(outputs),
    );
  }

  static String _getPythonVersion(int gen) {
    switch (gen) {
      case 1:
        return 'Python 2.6.6';
      case 2:
        return 'Python 2.7.5';
      case 3:
        return 'Python 3.6.8';
      case 4:
        return 'Python 3.9.7';
      default:
        return 'Python 2.6.6';
    }
  }

  static String _generateCdrScriptOutput(int gen) {
    final records = <String>[];

    for (var i = 0; i < 10; i++) {
      final record = _generateCdrRecord(gen, i);
      // Convert to CSV-like format
      final csvLine = [
        record['accountcode'],
        record['src'],
        record['dst'],
        record['dcontext'],
        record['clid'],
        record['channel'],
        record['dstchannel'],
        record['lastapp'],
        record['lastdata'],
        record['calldate'],
        record['duration'],
        record['billsec'],
        record['disposition'],
        record['amaflags'],
      ].join(',');

      records.add(csvLine);
    }

    return records.join('\n');
  }

  static String _generateExtensionsOutput(int gen) {
    final extensions = <String>[];

    for (var i = 100; i < 120; i++) {
      extensions.add('Extension: $i, Context: from-internal, Status: Available');
    }

    return extensions.join('\n');
  }

  static String _generateRecordingsList(int gen) {
    final recordings = <String>[];

    for (var i = 0; i < 20; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      recordings.add('/var/spool/asterisk/monitor/$dateStr/recording_$i.wav');
    }

    return recordings.join('\n');
  }

  static Future<void> _generateExtensionsData(int gen, String path) async {
    final extensions = <Map<String, dynamic>>[];

    for (var i = 100; i < 120; i++) {
      extensions.add({
        'extension': '$i',
        'context': 'from-internal',
        'priority': '1',
        'app': 'Dial',
        'appdata': 'SIP/trunk/$i',
        'status': i % 3 == 0 ? 'InUse' : 'Idle',
        'last_call': DateTime.now().subtract(Duration(minutes: i)).toIso8601String(),
      });
    }

    final file = File('$path/extensions.json');
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(extensions),
    );
  }

  static Future<void> _generateRecordings(int gen, String path) async {
    final recordings = <Map<String, dynamic>>[];

    for (var i = 0; i < 50; i++) {
      final date = DateTime.now().subtract(Duration(hours: i));
      recordings.add({
        'filename': 'recording_$i.wav',
        'path': '/var/spool/asterisk/monitor/${_getRecordingPath(gen, date)}',
        'size': '${100000 + i * 1000}',
        'duration': '${30 + i % 60}',
        'date': date.toIso8601String(),
        'channel': 'SIP/100${i % 10}',
        'extension': '091551190${i % 100}',
      });
    }

    final file = File('$path/recordings.json');
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(recordings),
    );
  }

  static String _getRecordingPath(int gen, DateTime date) {
    if (gen == 1) {
      return 'recording_${date.millisecondsSinceEpoch}.wav';
    } else {
      final dateStr = '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      return '$dateStr/recording_${date.millisecondsSinceEpoch}.wav';
    }
  }
}

void main() async {
  print('🛠️  Generating test fixtures for all generations...');

  try {
    await FixtureGenerator.generateAll();
    print('✅ All fixtures generated successfully!');
  } catch (e) {
    print('❌ Error generating fixtures: $e');
    exit(1);
  }
}