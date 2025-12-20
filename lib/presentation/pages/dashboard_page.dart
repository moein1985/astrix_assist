import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/refresh_settings.dart';
import '../../data/datasources/ami_datasource.dart';
import '../../data/repositories/extension_repository_impl.dart';
import '../../data/repositories/monitor_repository_impl.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_active_calls_usecase.dart';
import '../blocs/dashboard_bloc.dart';
import '../blocs/dashboard_event.dart';
import '../blocs/dashboard_state.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardBloc? _bloc;
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
    final extensionRepo = ExtensionRepositoryImpl(dataSource);
    final monitorRepo = MonitorRepositoryImpl(dataSource);
    final getDashboardStatsUseCase = GetDashboardStatsUseCase(extensionRepo, monitorRepo);
    final getActiveCallsUseCase = GetActiveCallsUseCase(monitorRepo);
    final bloc = DashboardBloc(getDashboardStatsUseCase, getActiveCallsUseCase);

    setState(() => _bloc = bloc);
    bloc.add(LoadDashboard());
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled && _bloc != null) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: _refreshSeconds),
        (_) => _bloc!.add(RefreshDashboard()),
      );
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
          title: const Text('داشبورد'),
          actions: [
            const ConnectionStatusWidget(),
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.timer_outlined),
              tooltip: 'Auto-refresh',
              onPressed: _showRefreshSettings,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => bloc.add(RefreshDashboard()),
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => switch (state) {
            DashboardInitial() => const SizedBox.shrink(),
            DashboardLoading() => const Center(child: CircularProgressIndicator()),
            DashboardLoaded() => RefreshIndicator(
              onRefresh: () async => bloc.add(RefreshDashboard()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsGrid(state),
                  const SizedBox(height: 24),
                  _buildRecentCallsSection(state),
                ],
              ),
            ),
            DashboardError() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => bloc.add(LoadDashboard()),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    final stats = state.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 24),
            const SizedBox(width: 8),
            const Text('آمار کلی', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              'آخرین به‌روزرسانی: ${_formatTime(stats.lastUpdate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'داخلی‌ها',
              '${stats.onlineExtensions}/${stats.totalExtensions}',
              'آنلاین',
              Icons.phone,
              Colors.blue,
            ),
            _buildStatCard(
              'تماس‌های فعال',
              '${stats.activeCalls}',
              'تماس',
              Icons.call,
              Colors.green,
            ),
            _buildStatCard(
              'صف‌ها',
              '${stats.queuedCalls}',
              'در انتظار',
              Icons.queue,
              Colors.orange,
            ),
            _buildStatCard(
              'میانگین انتظار',
              stats.averageWaitTime.toStringAsFixed(1),
              'ثانیه',
              Icons.timer,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCallsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_in_talk, size: 24),
                SizedBox(width: 8),
                Text('تماس‌های اخیر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: () => context.go('/calls'),
              child: const Text('مشاهده همه'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.recentCalls.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('تماس فعالی وجود ندارد', style: TextStyle(color: Colors.grey)),
              ),
            ),
          )
        else
          ...state.recentCalls.map((call) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.call, color: Colors.white, size: 20),
                  ),
                  title: Text('${call.caller} ➜ ${call.callee}'),
                  subtitle: Text(call.channel),
                  trailing: Text(
                    call.duration,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
                      const Text('به‌روزرسانی خودکار'),
                      Switch(
                        value: enabled,
                        onChanged: (val) => setModalState(() => enabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('فاصله زمانی: ${seconds.round()} ثانیه'),
                  Slider(
                    min: 5,
                    max: 60,
                    divisions: 11,
                    value: seconds,
                    onChanged: (val) => setModalState(() => seconds = val),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          RefreshSettings(enabled: enabled, intervalSeconds: seconds.round()),
                        );
                      },
                      child: const Text('ذخیره'),
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
