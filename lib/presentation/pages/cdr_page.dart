import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/cdr_datasource.dart';
import '../../data/repositories/cdr_repository_impl.dart';
import '../../domain/usecases/get_cdr_records_usecase.dart';
import '../../domain/usecases/export_cdr_to_csv_usecase.dart';
import '../blocs/cdr_bloc.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';

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

  Future<void> _initBloc() async {
    final prefs = await SharedPreferences.getInstance();
    // MySQL connection info - adjust these based on your setup
    final mysqlHost = prefs.getString('mysql_host') ?? '192.168.85.88';
    final mysqlPort =
        int.tryParse(prefs.getString('mysql_port') ?? '3306') ?? 3306;
    final mysqlUser = prefs.getString('mysql_user') ?? 'root';
    final mysqlPassword = prefs.getString('mysql_password') ?? '';
    final mysqlDb = prefs.getString('mysql_db') ?? 'asteriskcdrdb';

    final dataSource = CdrDataSource(
      host: mysqlHost,
      port: mysqlPort,
      user: mysqlUser,
      password: mysqlPassword,
      db: mysqlDb,
    );
    final repo = CdrRepositoryImpl(dataSource);
    final getCdrUseCase = GetCdrRecordsUseCase(repo);
    final exportUseCase = ExportCdrToCsvUseCase();
    final bloc = CdrBloc(
      getCdrRecordsUseCase: getCdrUseCase,
      exportCdrToCsvUseCase: exportUseCase,
    );

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
                content: Text('ذخیره شد: ${state.filePath}'),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is CdrExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا در ذخیره: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تاریخچه تماس‌ها (CDR)'),
            actions: [
              const ConnectionStatusWidget(),
              const ThemeToggleButton(),
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'فیلتر',
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadRecords,
              ),
            ],
          ),
          body: BlocBuilder<CdrBloc, CdrState>(
            builder: (context, state) {
              if (state is CdrLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CdrExporting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('در حال ذخیره...'),
                    ],
                  ),
                );
              } else if (state is CdrLoaded) {
                if (state.records.isEmpty) {
                  return const Center(child: Text('هیچ رکوردی یافت نشد'));
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
                              'تعداد: ${state.records.length} رکورد',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                bloc.add(ExportCdrRecords(state.records)),
                            icon: const Icon(Icons.download),
                            label: const Text('Export CSV'),
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
                                    'مدت: $durationStr • وضعیت: ${_translateDisposition(record.disposition)}',
                                  ),
                                ],
                              ),
                              trailing: Text(
                                _translateDisposition(record.disposition),
                                style: TextStyle(
                                  color: _getDispositionColor(
                                    record.disposition,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is CdrError) {
                return Center(
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
                        'خطا در بارگذاری داده‌ها',
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
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;
        String tempDisposition = _dispositionFilter;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('فیلتر تماس‌ها'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date range
                    const Text(
                      'بازه زمانی:',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                                  : 'از تاریخ',
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
                                  : 'تا تاریخ',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Source number
                    TextField(
                      controller: _srcController,
                      decoration: const InputDecoration(
                        labelText: 'شماره مبدا',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Destination number
                    TextField(
                      controller: _dstController,
                      decoration: const InputDecoration(
                        labelText: 'شماره مقصد',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disposition filter
                    const Text(
                      'وضعیت تماس:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempDisposition,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('همه')),
                        DropdownMenuItem(
                          value: 'ANSWERED',
                          child: Text('پاسخ داده شده'),
                        ),
                        DropdownMenuItem(
                          value: 'NO ANSWER',
                          child: Text('بدون پاسخ'),
                        ),
                        DropdownMenuItem(value: 'BUSY', child: Text('مشغول')),
                        DropdownMenuItem(
                          value: 'FAILED',
                          child: Text('ناموفق'),
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
                  child: const Text('انصراف'),
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
                  child: const Text('اعمال فیلتر'),
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

  String _translateDisposition(String disposition) {
    switch (disposition.toUpperCase()) {
      case 'ANSWERED':
        return 'پاسخ داده شده';
      case 'NO ANSWER':
        return 'بدون پاسخ';
      case 'BUSY':
        return 'مشغول';
      case 'FAILED':
        return 'ناموفق';
      default:
        return disposition;
    }
  }
}
