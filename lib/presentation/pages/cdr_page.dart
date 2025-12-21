import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/injection_container.dart';
import '../../core/ami_api.dart';
import '../blocs/cdr_bloc.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/recording_player.dart';

class CdrPage extends StatefulWidget {
  const CdrPage({super.key});

  @override
  State<CdrPage> createState() => _CdrPageState();
}

class _CdrPageState extends State<CdrPage> {
  CdrBloc? _bloc;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _srcFilter;
  String? _dstFilter;
  String _dispositionFilter = 'ALL';

  final _srcController = TextEditingController();
  final _dstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default: last 7 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 7));
    _initBloc();
  }

  /// Fetch a recording stream URL via the configured `AmiApi` (mock or real backend).
  Future<String?> _fetchRecordingUrl(String uniqueId) async {
    try {
      final res = await AmiApi.getRecordingMeta(uniqueId);
      if (res.statusCode == 200 && res.data != null) {
        final url = (res.data as Map<String, dynamic>)['url'] as String?;
        if (url != null && url.isNotEmpty) return url;
      }
    } catch (_) {}

    // fallback: get list and return first item's url
    try {
      final res2 = await AmiApi.getRecordings();
      if (res2.statusCode == 200 && res2.data is List && (res2.data as List).isNotEmpty) {
        final first = (res2.data as List).first as Map<String, dynamic>;
        return first['url'] as String?;
      }
    } catch (_) {}

    return null;
  }

  Future<void> _initBloc() async {
    // Use GetIt to get the bloc (which uses the correct repository based on AppConfig)
    final bloc = sl<CdrBloc>();

    setState(() => _bloc = bloc);
    _loadRecords();
  }

  void _loadRecords() {
    _bloc?.add(
      LoadCdrRecords(
        startDate: _startDate,
        endDate: _endDate,
        src: _srcFilter,
        dst: _dstFilter,
        disposition: _dispositionFilter == 'ALL' ? null : _dispositionFilter,
      ),
    );
  }

  @override
  void dispose() {
    _srcController.dispose();
    _dstController.dispose();
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
      child: BlocListener<CdrBloc, CdrState>(
        listener: (context, state) {
          if (state is CdrExported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.saved}: ${state.filePath}'),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is CdrExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.saveError}: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.cdrTitle),
            actions: [
              const ConnectionStatusWidget(),
              const ThemeToggleButton(),
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: l10n.filter,
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadRecords,
              ),
            ],
          ),
          body: BlocBuilder<CdrBloc, CdrState>(
            builder: (context, state) => _buildBody(context, state, l10n, bloc),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CdrState state, AppLocalizations l10n, CdrBloc bloc) {
    return switch (state) {
      CdrInitial() => const SizedBox.shrink(),
      CdrLoading() => const Center(child: CircularProgressIndicator()),
      CdrExporting() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.saving),
          ],
        ),
      ),
      CdrLoaded() => () {
        if (state.records.isEmpty) {
          return Center(child: Text(l10n.noRecords));
        }
        return Column(
          children: [
            // Export button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.recordCount}: ${state.records.length} ${l10n.records}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        bloc.add(ExportCdrRecords(state.records)),
                    icon: const Icon(Icons.download),
                    label: Text(l10n.exportCsv),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  final duration = int.tryParse(record.billsec) ?? 0;
                  final durationStr = _formatDuration(duration);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getDispositionIcon(record.disposition),
                        color: _getDispositionColor(record.disposition),
                      ),
                      title: Text('${record.src} ➜ ${record.dst}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatCallDate(record.callDate)),
                          Text(
                            '${l10n.duration}: $durationStr • ${l10n.status}: ${_translateDisposition(record.disposition, l10n)}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Play recording',
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final l10nLocal = l10n;
                              // Use uniqueid or userfield as recording id
                              final id = record.userfield.isNotEmpty ? record.userfield : record.uniqueid;
                              final url = await _fetchRecordingUrl(id);
                              if (url != null && url.isNotEmpty) {
                                if (!mounted) return;
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (_) => RecordingPlayerPage(url: url, title: '${record.src} -> ${record.dst}'),
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l10nLocal.noRecords)),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _translateDisposition(record.disposition, l10n),
                            style: TextStyle(
                              color: _getDispositionColor(
                                record.disposition,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }(),
      CdrError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadingError,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecords,
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
      CdrExported() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.fileSaved,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.path}: ${state.filePath}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      CdrExportError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.fileSaveError,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    };
  }

  Future<void> _showFilterDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;
        String tempDisposition = _dispositionFilter;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.filterCalls),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date range
                    Text(
                      '${l10n.dateRange}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() => tempStartDate = date);
                              }
                            },
                            child: Text(
                              tempStartDate != null
                                  ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(tempStartDate!)
                                  : l10n.fromDate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempEndDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() => tempEndDate = date);
                              }
                            },
                            child: Text(
                              tempEndDate != null
                                  ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(tempEndDate!)
                                  : l10n.toDate,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Source number
                    TextField(
                      controller: _srcController,
                      decoration: InputDecoration(
                        labelText: l10n.sourceNumber,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Destination number
                    TextField(
                      controller: _dstController,
                      decoration: InputDecoration(
                        labelText: l10n.destinationNumber,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disposition filter
                    Text(
                      '${l10n.callStatus}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempDisposition,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'ALL', child: Text(l10n.all)),
                        DropdownMenuItem(
                          value: 'ANSWERED',
                          child: Text(l10n.answered),
                        ),
                        DropdownMenuItem(
                          value: 'NO ANSWER',
                          child: Text(l10n.noAnswer),
                        ),
                        DropdownMenuItem(value: 'BUSY', child: Text(l10n.busy)),
                        DropdownMenuItem(
                          value: 'FAILED',
                          child: Text(l10n.failed),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => tempDisposition = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                      _srcFilter = _srcController.text.trim().isEmpty
                          ? null
                          : _srcController.text.trim();
                      _dstFilter = _dstController.text.trim().isEmpty
                          ? null
                          : _dstController.text.trim();
                      _dispositionFilter = tempDisposition;
                    });
                    Navigator.of(context).pop();
                    _loadRecords();
                  },
                  child: Text(l10n.applyFilter),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatCallDate(String callDate) {
    try {
      final dt = DateTime.parse(callDate);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    } catch (e) {
      return callDate;
    }
  }

  IconData _getDispositionIcon(String disposition) {
    switch (disposition.toUpperCase()) {
      case 'ANSWERED':
        return Icons.check_circle;
      case 'NO ANSWER':
        return Icons.phone_missed;
      case 'BUSY':
        return Icons.phone_locked;
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Color _getDispositionColor(String disposition) {
    switch (disposition.toUpperCase()) {
      case 'ANSWERED':
        return Colors.green;
      case 'NO ANSWER':
        return Colors.orange;
      case 'BUSY':
        return Colors.amber;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _translateDisposition(String disposition, AppLocalizations l10n) {
    switch (disposition.toUpperCase()) {
      case 'ANSWERED':
        return l10n.answered;
      case 'NO ANSWER':
        return l10n.noAnswer;
      case 'BUSY':
        return l10n.busy;
      case 'FAILED':
        return l10n.failed;
      default:
        return disposition;
    }
  }
}
