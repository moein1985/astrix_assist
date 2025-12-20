import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/refresh_settings.dart';
import '../../data/datasources/ami_datasource.dart';
import '../../data/repositories/extension_repository_impl.dart';
import '../../domain/usecases/get_extensions_usecase.dart';
import '../blocs/extension_bloc.dart';
import '../../domain/entities/extension.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';

class ExtensionsPage extends StatefulWidget {
  const ExtensionsPage({super.key});

  @override
  State<ExtensionsPage> createState() => _ExtensionsPageState();
}

class _ExtensionsPageState extends State<ExtensionsPage> {
  ExtensionBloc? _bloc;
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
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
    final repository = ExtensionRepositoryImpl(dataSource);
    final useCase = GetExtensionsUseCase(repository);
    final bloc = ExtensionBloc(useCase);

    setState(() => _bloc = bloc);
    bloc.add(LoadExtensions());
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled && _bloc != null) {
      _refreshTimer = Timer.periodic(Duration(seconds: _refreshSeconds), (_) {
        _bloc!.add(LoadExtensions());
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bloc?.close();
    _searchController.dispose();
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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('داخلی‌ها'),
            actions: [
              const ConnectionStatusWidget(),
              const ThemeToggleButton(),
              IconButton(
                icon: const Icon(Icons.phone_forwarded),
                tooltip: 'Originate',
                onPressed: () => context.push('/originate'),
              ),
              IconButton(
                icon: const Icon(Icons.timer_outlined),
                tooltip: 'Auto-refresh',
                onPressed: _showRefreshSettings,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => bloc.add(LoadExtensions()),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Online'),
              ],
            ),
          ),
          body: BlocBuilder<ExtensionBloc, ExtensionState>(
            builder: (context, state) {
              if (state is ExtensionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ExtensionLoaded) {
                final allExtensions = _applyFilter(state.extensions);
                final onlineExtensions = allExtensions.where((e) => e.isOnline).toList();
                final total = allExtensions.length;
                final online = onlineExtensions.length;
                final offline = total - online;

                return Column(
                  children: [
                    _buildDashboard(total, online, offline),
                    _buildSearchBar(),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildList(allExtensions),
                          _buildList(onlineExtensions),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is ExtensionError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => bloc.add(LoadExtensions()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('Press refresh to load'));
            },
          ),
        ),
      ),
    );
  }

  List<Extension> _applyFilter(List<Extension> list) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List<Extension>.from(list);
    return list.where((e) {
      final name = e.name.toLowerCase();
      final loc = e.location.toLowerCase();
      return name.contains(q) || loc.contains(q);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'جستجو بر اساس شماره یا IP',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _showRefreshSettings() async {
    if (_bloc == null) return;
    
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

  Widget _buildDashboard(int total, int online, int offline) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildStatCard('Total', total.toString(), Colors.blue),
          _buildStatCard('Online', online.toString(), Colors.green),
          _buildStatCard('Offline', offline.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Extension> extensions) {
    if (extensions.isEmpty) {
      return const Center(child: Text('No extensions found'));
    }
    return ListView.builder(
      itemCount: extensions.length,
      itemBuilder: (context, index) {
        final ext = extensions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ext.isOnline ? Colors.green : Colors.grey,
              child: Icon(
                ext.isTrunk ? Icons.router : Icons.phone,
                color: Colors.white,
              ),
            ),
            title: Text(
              ext.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ext.location.isNotEmpty ? ext.location : 'No IP'),
                if (ext.isOnline && ext.latency != null)
                  Row(
                    children: [
                      Icon(Icons.network_check, size: 16, color: _getLatencyColor(ext.latency!)),
                      const SizedBox(width: 4),
                      Text(
                        '${ext.latency} ms',
                        style: TextStyle(color: _getLatencyColor(ext.latency!)),
                      ),
                    ],
                  ),
              ],
            ),
            trailing: ext.isOnline
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.grey),
            onTap: () => context.push('/extension', extra: ext),
          ),
        );
      },
    );
  }

  Color _getLatencyColor(int latency) {
    if (latency < 100) return Colors.green;
    if (latency < 200) return Colors.orange;
    return Colors.red;
  }
}