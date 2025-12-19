import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/ami_datasource.dart';
import '../../data/repositories/monitor_repository_impl.dart';
import '../../domain/usecases/get_active_calls_usecase.dart';
import '../../domain/usecases/hangup_call_usecase.dart';
import '../../core/refresh_settings.dart';
import '../blocs/active_call_bloc.dart';
import '../widgets/theme_toggle_button.dart';

class ActiveCallsPage extends StatefulWidget {
  const ActiveCallsPage({super.key});

  @override
  State<ActiveCallsPage> createState() => _ActiveCallsPageState();
}

class _ActiveCallsPageState extends State<ActiveCallsPage> {
  ActiveCallBloc? _bloc;
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
    final getCallsUseCase = GetActiveCallsUseCase(repo);
    final hangupUseCase = HangupCallUseCase(repo);
    final bloc = ActiveCallBloc(getCallsUseCase, hangupUseCase);

    setState(() => _bloc = bloc);
    bloc.add(LoadActiveCalls());
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled && _bloc != null) {
      _refreshTimer = Timer.periodic(Duration(seconds: _refreshSeconds), (_) => _bloc!.add(LoadActiveCalls()));
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
          title: const Text('تماس‌های فعال'),
          actions: [
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.timer_outlined),
              tooltip: 'Auto-refresh',
              onPressed: _showRefreshSettings,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => bloc.add(LoadActiveCalls()),
            ),
          ],
        ),
        body: BlocBuilder<ActiveCallBloc, ActiveCallState>(
          builder: (context, state) {
            if (state is ActiveCallLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ActiveCallLoaded) {
              if (state.calls.isEmpty) {
                return const Center(child: Text('No active calls'));
              }
              return ListView.builder(
                itemCount: state.calls.length,
                itemBuilder: (context, index) {
                  final call = state.calls[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.call, color: Colors.green),
                      title: Text('${call.caller} ➜ ${call.callee}'),
                      subtitle: Text('${call.channel}\nDuration: ${call.duration}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.red),
                        tooltip: 'Hangup',
                        onPressed: () => bloc.add(HangupCall(call.channel)),
                      ),
                    ),
                  );
                },
              );
            } else if (state is ActiveCallError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => bloc.add(LoadActiveCalls()),
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
}
