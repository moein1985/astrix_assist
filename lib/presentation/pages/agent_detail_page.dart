import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/ami_datasource.dart';
import '../../data/repositories/monitor_repository_impl.dart';
import '../../domain/usecases/get_agent_details_usecase.dart';
import '../../domain/usecases/pause_agent_usecase.dart';
import '../../domain/usecases/unpause_agent_usecase.dart';
import '../blocs/agent_detail_bloc.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/pause_reason_dialog.dart';

class AgentDetailPage extends StatefulWidget {
  final String agentInterface;
  final String agentName;

  const AgentDetailPage({
    super.key,
    required this.agentInterface,
    required this.agentName,
  });

  @override
  State<AgentDetailPage> createState() => _AgentDetailPageState();
}

class _AgentDetailPageState extends State<AgentDetailPage> {
  AgentDetailBloc? _bloc;

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

    final dataSource = AmiDataSource(host: host, port: port, username: user, secret: secret);
    final repo = MonitorRepositoryImpl(dataSource);
    final getDetailsUseCase = GetAgentDetailsUseCase(repo);
    final pauseUseCase = PauseAgentUseCase(repo);
    final unpauseUseCase = UnpauseAgentUseCase(repo);
    
    final bloc = AgentDetailBloc(
      getAgentDetailsUseCase: getDetailsUseCase,
      pauseAgentUseCase: pauseUseCase,
      unpauseAgentUseCase: unpauseUseCase,
    );

    setState(() => _bloc = bloc);
    bloc.add(LoadAgentDetails(widget.agentInterface));
  }

  @override
  void dispose() {
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
          title: Text('جزئیات ${widget.agentName}'),
          actions: [
            const ConnectionStatusWidget(),
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => bloc.add(LoadAgentDetails(widget.agentInterface)),
            ),
          ],
        ),
        body: BlocBuilder<AgentDetailBloc, AgentDetailState>(
          builder: (context, state) {
            if (state is AgentDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AgentDetailLoaded) {
              final details = state.details;
              return RefreshIndicator(
                onRefresh: () async {
                  bloc.add(LoadAgentDetails(widget.agentInterface));
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 48,
                                  color: _getStateColor(details.state),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        details.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        details.interface,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'وضعیت',
                              _translateState(details.state),
                              color: _getStateColor(details.state),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'توقف',
                              details.paused ? 'بله' : 'خیر',
                              color: details.paused ? Colors.red : Colors.green,
                            ),
                            if (details.paused && details.pauseReason != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'دلیل توقف',
                                details.pauseReason!,
                                color: Colors.orange,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'تماس‌های امروز',
                            details.callsAnsweredToday.toString(),
                            Icons.call_received,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'کل تماس‌ها',
                            details.callsTaken.toString(),
                            Icons.phone_in_talk,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'آخرین تماس',
                            _formatLastCall(details.lastCall),
                            Icons.access_time,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'میانگین مکالمه',
                            details.averageTalkTime > 0
                                ? '${details.averageTalkTime.toStringAsFixed(1)}s'
                                : 'N/A',
                            Icons.timer,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Queues section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.queue, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'صف‌های عضو',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (details.queues.isEmpty)
                              const Text('عضو هیچ صفی نیست')
                            else
                              ...details.queues.map((queue) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.arrow_right, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(queue)),
                                        IconButton(
                                          icon: Icon(
                                            details.paused ? Icons.play_arrow : Icons.pause,
                                            color: details.paused ? Colors.green : Colors.orange,
                                          ),
                                          tooltip: details.paused ? 'فعال‌سازی' : 'توقف',
                                          onPressed: () => _togglePause(
                                            context,
                                            queue,
                                            details.interface,
                                            details.paused,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AgentDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'خطا در بارگذاری اطلاعات',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => bloc.add(LoadAgentDetails(widget.agentInterface)),
                      child: const Text('تلاش مجدد'),
                    ),
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

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastCall(int seconds) {
    if (seconds == 0) return 'هرگز';
    
    final duration = Duration(seconds: seconds);
    if (duration.inDays > 0) {
      return '${duration.inDays} روز پیش';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعت پیش';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقیقه پیش';
    } else {
      return 'اکنون';
    }
  }

  String _translateState(String state) {
    switch (state) {
      case 'Ready':
        return 'آماده';
      case 'In Use':
      case 'Busy':
        return 'مشغول';
      case 'Paused':
        return 'متوقف';
      case 'Unavailable':
        return 'در دسترس نیست';
      case 'Ringing':
        return 'در حال زنگ';
      default:
        return state;
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'Ready':
        return Colors.green;
      case 'In Use':
      case 'Busy':
        return Colors.orange;
      case 'Paused':
        return Colors.blueGrey;
      case 'Unavailable':
        return Colors.red;
      case 'Ringing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _togglePause(BuildContext context, String queue, String interface, bool currentlyPaused) async {
    final bloc = _bloc;
    if (bloc == null) return;

    if (currentlyPaused) {
      bloc.add(UnpauseAgentFromDetail(queue: queue, interface: interface));
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اپراتور فعال شد')),
        );
      }
    } else {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => const PauseReasonDialog(),
      );

      if (reason != null) {
        bloc.add(PauseAgentFromDetail(queue: queue, interface: interface, reason: reason));
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اپراتور متوقف شد')),
          );
        }
      }
    }
  }
}
