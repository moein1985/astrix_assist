import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/refresh_settings.dart';
import '../../core/injection_container.dart';
import '../../core/ami_listen_client.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/active_call_bloc.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/call_duration_widget.dart';
import '../widgets/transfer_dialog.dart';
import '../widgets/listen_consent_dialog.dart';

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
    final settings = await RefreshSettings.load();
    _autoRefreshEnabled = settings.enabled;
    _refreshSeconds = settings.intervalSeconds;

    // Use GetIt to get the bloc (which uses the correct repository based on AppConfig)
    final bloc = sl<ActiveCallBloc>();

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
    final l10n = AppLocalizations.of(context)!;
    final bloc = _bloc;
    if (bloc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.activeCalls),
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
              onPressed: () => bloc.add(LoadActiveCalls()),
            ),
          ],
        ),
        body: BlocBuilder<ActiveCallBloc, ActiveCallState>(
          builder: (context, state) => switch (state) {
            ActiveCallInitial() => const SizedBox.shrink(),
            ActiveCallLoading() => const Center(child: CircularProgressIndicator()),
            ActiveCallLoaded() => () {
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(call.channel),
                          const SizedBox(height: 4),
                          CallDurationWidget(durationString: call.duration),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_forwarded, color: Colors.blue),
                            tooltip: 'انتقال',
                            onPressed: () => _showTransferDialog(context, call.channel),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call_end, color: Colors.red),
                            tooltip: 'قطع',
                            onPressed: () => bloc.add(HangupCall(call.channel)),
                          ),
                              IconButton(
                                icon: const Icon(Icons.hearing, color: Colors.black87),
                                tooltip: 'Listen Live',
                                onPressed: () => _onListenPressed(call.channel),
                              ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }(),
            ActiveCallError() => Center(
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
            ),
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

  Future<void> _showTransferDialog(BuildContext context, String channel) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => TransferDialog(currentChannel: channel),
    );

    if (result != null && _bloc != null) {
      _bloc!.add(TransferCall(
        channel: channel,
        destination: result['destination']!,
        context: result['context']!,
      ));
      
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('در حال انتقال به ${result['destination']}...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _onListenPressed(String target) async {
    print('🎧 Listen button pressed for target: $target');
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    
    // Check consent first
    print('📋 Showing consent dialog...');
    final hasConsent = await ListenConsentDialog.showConsentDialog(context, target);
    print('📋 Consent result: $hasConsent');
    if (!hasConsent || !mounted) {
      print('❌ Consent denied or widget unmounted');
      return;
    }
    
    final title = 'Listen Live';
    final confirmLabel = 'Confirm';
    final cancelLabel = l10n.cancel;
    print('📋 Showing confirmation dialog...');
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text('$confirmLabel: $target'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel)),
        ],
      ),
    );
    print('📋 Confirmation result: $should');
    if (should != true) {
      print('❌ User cancelled confirmation');
      return;
    }

    try {
      print('🎧 Starting listen session for: $target');
      // استفاده مستقیم از AmiListenClient
      final amiClient = sl<AmiListenClient>();
      print('📞 AMI client obtained, calling originateListen...');
      
      // فرض: target به فرمت SIP/1001 است
      // شنود را شروع کن
      await amiClient.originateListen(
        targetChannel: target,
        listenerExtension: '9999', // داخلی برای شنود - باید از تنظیمات بیاید
      );
      print('✅ Listen session started successfully');
      
      messenger.showSnackBar(
        SnackBar(content: Text('Listen session started for $target')),
      );
    } catch (e) {
      print('❌ Error starting listen session: $e');
      messenger.showSnackBar(SnackBar(content: Text('Error starting listen: $e')));
    }
  }
}
