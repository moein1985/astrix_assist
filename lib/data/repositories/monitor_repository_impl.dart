import '../../domain/entities/active_call.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/entities/trunk.dart';
import '../../domain/entities/parked_call.dart';
import '../../domain/repositories/imonitor_repository.dart';
import '../datasources/ami_datasource.dart';
import '../models/active_call_model.dart';
import '../models/queue_status_model.dart';
import '../models/trunk_model.dart';
import '../models/parked_call_model.dart';

class MonitorRepositoryImpl implements IMonitorRepository {
  final AmiDataSource dataSource;
  // Keep logs minimal here; details are already handled in datasource if needed.

  MonitorRepositoryImpl(this.dataSource);

  @override
  Future<List<ActiveCall>> getActiveCalls() async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    final events = await dataSource.getActiveCalls();
    dataSource.disconnect();
    
    print('📞 [ActiveCalls] Raw events count: ${events.length}');
    
    // لاگ کردن رویداد کامل برای دیباگ
    for (int i = 0; i < events.length; i++) {
      print('📞 ========== Event $i RAW START ==========');
      print(events[i]);
      print('📞 ========== Event $i RAW END ==========');
      
      final lines = events[i].split(RegExp(r'\r\n|\n'));
      String channel = '';
      String state = '';
      String channelStateDesc = '';
      
      for (final line in lines) {
        if (line.startsWith('Channel: ')) channel = line.substring(9);
        if (line.startsWith('ChannelState: ')) state = line.substring(14);
        if (line.startsWith('ChannelStateDesc: ')) channelStateDesc = line.substring(18);
      }
      
      print('📞 [Parsed] Event $i:');
      print('   Channel: $channel');
      print('   State: $state');
      print('   StateDesc: $channelStateDesc');
    }
    
    // فیلتر کردن کانال‌های غیر کاربری (internal channels)
    final filtered = events.where((e) {
      final lowerCase = e.toLowerCase();
      
      // بررسی Channel name
      final lines = e.split(RegExp(r'\r\n|\n'));
      String channel = '';
      String channelState = '';
      
      for (final line in lines) {
        if (line.startsWith('Channel: ')) channel = line.substring(9);
        if (line.startsWith('ChannelStateDesc: ')) channelState = line.substring(18);
      }
      
      // فیلتر کانال‌های سیستمی بر اساس نام کانال
      bool isSystemChannel = channel.toLowerCase().contains('voicemail') ||
                             channel.toLowerCase().contains('parked') ||
                             channel.toLowerCase().contains('confbridge') ||
                             channel.toLowerCase().contains('meetme') ||
                             channel.toLowerCase().contains('local@');
      
      // اگر کانال در حالت Up باشد و SIP/PJSIP باشد، احتمالاً تماس واقعی است
      bool isProbablyRealCall = (channel.startsWith('SIP/') || channel.startsWith('PJSIP/')) &&
                                channelState.toLowerCase() == 'up';
      
      bool keep = !isSystemChannel && isProbablyRealCall;
      
      print('📞 [Filter] Channel: $channel, Keep: $keep, IsSystem: $isSystemChannel, IsRealCall: $isProbablyRealCall');
      
      return keep;
    }).toList();
    
    print('📞 [ActiveCalls] Filtered count: ${filtered.length}');
    
    return filtered.map((e) => ActiveCallModel.fromAmi(e)).toList();
  }

  @override
  Future<List<QueueStatus>> getQueueStatuses() async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    final events = await dataSource.getQueueStatuses();
    dataSource.disconnect();
    final Map<String, List<String>> grouped = {};
    for (final e in events) {
      final queue = _extractQueueName(e);
      if (queue.isEmpty) continue;
      grouped.putIfAbsent(queue, () => []).add(e);
    }
    return grouped.entries
        .map((entry) => QueueStatusModel.fromEvents(entry.key, entry.value))
        .toList();
  }

  String _extractQueueName(String event) {
    final lines = event.split(RegExp('\\r\\n|\\n'));
    for (final line in lines) {
      if (line.startsWith('Queue: ')) {
        return line.substring(7);
      }
    }
    return '';
  }

  @override
  Future<void> hangup(String channel) async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    await dataSource.hangup(channel);
    dataSource.disconnect();
  }

  @override
  Future<void> originate({required String from, required String to, required String context}) async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    await dataSource.originate(channel: from, exten: to, context: context);
    dataSource.disconnect();
  }

  @override
  Future<void> transfer({required String channel, required String destination, required String context}) async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    await dataSource.transfer(channel: channel, exten: destination, context: context);
    dataSource.disconnect();
  }

  @override
  Future<void> pauseAgent({required String queue, required String interface, required bool paused, String? reason}) async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    await dataSource.pauseAgent(queue: queue, interface: interface, paused: paused, reason: reason);
    dataSource.disconnect();
  }

  Future<List<Trunk>> getTrunks() async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    final events = await dataSource.getSIPRegistry();
    dataSource.disconnect();
    return events.map((e) => TrunkModel.fromAmi(e)).toList();
  }

  Future<List<ParkedCall>> getParkedCalls() async {
    await dataSource.connect();
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    final events = await dataSource.getParkedCalls();
    dataSource.disconnect();
    return events.map((e) => ParkedCallModel.fromAmi(e)).toList();
  }
}
