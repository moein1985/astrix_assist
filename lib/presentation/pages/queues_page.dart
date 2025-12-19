import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/ami_datasource.dart';
import '../../data/repositories/monitor_repository_impl.dart';
import '../../domain/usecases/get_queue_status_usecase.dart';
import '../../core/refresh_settings.dart';
import '../blocs/queue_bloc.dart';
import '../widgets/theme_toggle_button.dart';

class QueuesPage extends StatefulWidget {
  const QueuesPage({super.key});

  @override
  State<QueuesPage> createState() => _QueuesPageState();
}

class _QueuesPageState extends State<QueuesPage> {
  QueueBloc? _bloc;
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = true;
  int _refreshSeconds = RefreshSettings.defaultIntervalSeconds;

  @override
  void initState() {
    super.initState();
    _initBloc();
  }

  Future<void> _initBloc() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('ip') ?? '192.168.85.88';
    final port = int.tryParse(prefs.getString('port') ?? '5038') ?? 5038;
    final user = prefs.getString('username') ?? 'moein_api';
    final secret = prefs.getString('password') ?? '123456';

    final settings = await RefreshSettings.load();
    _autoRefreshEnabled = settings.enabled;
    _refreshSeconds = settings.intervalSeconds;

    final dataSource = AmiDataSource(host: host, port: port, username: user, secret: secret);
    final repo = MonitorRepositoryImpl(dataSource);
    final useCase = GetQueueStatusUseCase(repo);
    final bloc = QueueBloc(useCase);

    setState(() => _bloc = bloc);
    bloc.add(LoadQueues());
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled && _bloc != null) {
      _refreshTimer = Timer.periodic(Duration(seconds: _refreshSeconds), (_) => _bloc!.add(LoadQueues()));
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('صف‌ها'),
          actions: [
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.timer_outlined),
              tooltip: 'Auto-refresh',
              onPressed: _showRefreshSettings,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => bloc.add(LoadQueues()),
            ),
          ],
        ),
        body: BlocBuilder<QueueBloc, QueueState>(
          builder: (context, state) {
            if (state is QueueLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QueueLoaded) {
              if (state.queues.isEmpty) {
                return const Center(child: Text('No queues found'));
              }
              return ListView.builder(
                itemCount: state.queues.length,
                itemBuilder: (context, index) {
                  final q = state.queues[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.queue, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.queue,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Waiting: ${q.calls} | Avg Wait: ${q.holdTime}s | Talk: ${q.talkTime}s | Done: ${q.completed}'),
                          const SizedBox(height: 8),
                          if (q.members.isNotEmpty) ...[
                            const Text('Agents:'),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: q.members
                                  .map(
                                    (m) => Chip(
                                      avatar: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: _memberColor(m.state),
                                      ),
                                      label: Text('${m.name} • ${m.state}'),
                                      backgroundColor: _memberColor(m.state).withOpacity(0.12),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ] else
                            const Text('No agents reported'),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is QueueError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => bloc.add(LoadQueues()),
                      child: const Text('Retry'),
                    )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _showRefreshSettings() async {
    final newSettings = await showModalBottomSheet<RefreshSettings>(
      context: context,
      builder: (context) {
        bool enabled = _autoRefreshEnabled;
        double seconds = _refreshSeconds.toDouble();
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto-refresh'),
                      Switch(
                        value: enabled,
                        onChanged: (val) => setModalState(() => enabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Interval: ${seconds.round()}s'),
                  Slider(
                    min: 5,
                    max: 60,
                    divisions: 11,
                    value: seconds,
                    onChanged: (val) => setModalState(() => seconds = val),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          RefreshSettings(enabled: enabled, intervalSeconds: seconds.round()),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (newSettings != null) {
      await RefreshSettings.save(newSettings);
      setState(() {
        _autoRefreshEnabled = newSettings.enabled;
        _refreshSeconds = newSettings.intervalSeconds;
      });
      _startTimer();
    }
  }

  Color _memberColor(String state) {
    switch (state) {
      case 'Ready':
        return Colors.green;
      case 'In Use':
      case 'Busy':
        return Colors.orange;
      case 'Paused':
      case 'On Hold':
        return Colors.blueGrey;
      case 'Unavailable':
        return Colors.red;
      case 'Ringing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
