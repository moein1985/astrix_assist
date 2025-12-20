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
    return events.map((e) => ActiveCallModel.fromAmi(e)).toList();
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
