import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/refresh_settings.dart';
import '../../core/injection_container.dart';
import '../../core/locale_manager.dart';
import '../../domain/services/server_manager.dart';
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
    final settings = await RefreshSettings.load();
    _autoRefreshEnabled = settings.enabled;
    _refreshSeconds = settings.intervalSeconds;

    // Use GetIt to get the bloc (which uses the correct repository based on AppConfig)
    final bloc = sl<DashboardBloc>();

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
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();
    
    if (bloc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: bloc,
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.dashboard),
            actions: [
              const ConnectionStatusWidget(),
              const ThemeToggleButton(),
              IconButton(
                icon: const Icon(Icons.timer_outlined),
                tooltip: l10n.autoRefresh,
                onPressed: _showRefreshSettings,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                onPressed: () => bloc.add(RefreshDashboard()),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: l10n.logout,
                onPressed: () => _showLogoutDialog(context, l10n),
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
                    _buildStatsGrid(state, l10n),
                    const SizedBox(height: 24),
                    _buildRecentCallsSection(state, l10n),
                  ],
                ),
              ),
              DashboardError() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${l10n.error}: ${state.message}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => bloc.add(LoadDashboard()),
                      child: Text(l10n.retryButton),
                    ),
                  ],
                ),
              ),
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ServerManager.clearActiveServer();
              if (context.mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state, AppLocalizations l10n) {
    final stats = state.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 24),
            const SizedBox(width: 8),
            Text(l10n.overallStats, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              '${l10n.lastUpdated}: ${_formatTime(stats.lastUpdate)}',
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
              l10n.extensions,
              '${stats.onlineExtensions}/${stats.totalExtensions}',
              l10n.online,
              Icons.phone,
              Colors.blue,
            ),
            _buildStatCard(
              l10n.activeCalls,
              '${stats.activeCalls}',
              l10n.call,
              Icons.call,
              Colors.green,
            ),
            _buildStatCard(
              l10n.queues,
              '${stats.queuedCalls}',
              l10n.waiting,
              Icons.queue,
              Colors.orange,
            ),
            _buildStatCard(
              l10n.averageWait,
              stats.averageWaitTime.toStringAsFixed(1),
              l10n.seconds,
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

  Widget _buildRecentCallsSection(DashboardLoaded state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_in_talk, size: 24),
                const SizedBox(width: 8),
                Text(l10n.recentCalls, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: () => context.go('/calls'),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.recentCalls.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(l10n.noActiveCalls, style: const TextStyle(color: Colors.grey)),
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
    final l10n = AppLocalizations.of(context)!;
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
                      Text(l10n.autoRefresh),
                      Switch(
                        value: enabled,
                        onChanged: (val) => setModalState(() => enabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${l10n.interval}: ${seconds.round()} ${l10n.seconds}'),
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
                      child: Text(l10n.save),
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
