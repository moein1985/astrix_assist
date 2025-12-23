import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_config.dart';
import 'ssh_config.dart';
import 'services/asterisk_ssh_manager.dart';
import 'ami_listen_client.dart';
import '../domain/usecases/get_extensions_usecase.dart';
import '../domain/usecases/pause_agent_usecase.dart';
import '../domain/usecases/unpause_agent_usecase.dart';
import '../domain/usecases/get_queue_status_usecase.dart';
import '../domain/usecases/get_agent_details_usecase.dart';
import '../domain/usecases/get_cdr_records_usecase.dart';
import '../domain/usecases/export_cdr_to_csv_usecase.dart';
import '../domain/usecases/get_trunks_usecase.dart';
import '../domain/usecases/get_parked_calls_usecase.dart';
import '../domain/usecases/get_dashboard_stats_usecase.dart';
import '../domain/usecases/get_active_calls_usecase.dart';
import '../domain/usecases/hangup_call_usecase.dart';
import '../domain/usecases/transfer_call_usecase.dart';
import '../domain/usecases/originate_call_usecase.dart';
import '../data/datasources/ami_datasource.dart';
import '../data/datasources/ssh_cdr_datasource.dart';
import '../data/datasources/ssh_system_datasource.dart';
import '../data/repositories/extension_repository_impl.dart';
import '../data/repositories/monitor_repository_impl.dart';
import '../data/repositories/cdr_repository_impl.dart';
import '../data/repositories/mock/extension_repository_mock.dart';
import '../data/repositories/mock/monitor_repository_mock.dart';
import '../data/repositories/mock/cdr_repository_mock.dart';
import '../domain/repositories/iextension_repository.dart';
import '../domain/repositories/imonitor_repository.dart';
import '../domain/repositories/icdr_repository.dart';
import '../presentation/blocs/extension_bloc.dart';
import '../presentation/blocs/queue_bloc.dart';
import '../presentation/blocs/agent_detail_bloc.dart';
import '../presentation/blocs/cdr_bloc.dart';
import '../presentation/blocs/trunk_bloc.dart';
import '../presentation/blocs/parking_bloc.dart';
import '../presentation/blocs/dashboard_bloc.dart';
import '../presentation/blocs/active_call_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // جلوگیری از ثبت مجدد
  if (sl.isRegistered<IExtensionRepository>()) {
    return;
  }
  
  // استفاده از AppConfig برای تعیین Mock یا Real
  const useMock = AppConfig.useMockRepositories;

  // Load saved settings
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  
  // SSH Config from saved settings or defaults
  final sshHost = prefs.getString('ssh_host') ?? AppConfig.defaultSshHost;
  final sshPort = prefs.getInt('ssh_port') ?? AppConfig.defaultSshPort;
  final sshUsername = prefs.getString('ssh_username') ?? AppConfig.defaultSshUsername;
  final sshPassword = await secureStorage.read(key: 'ssh_password') ?? '';
  
  // AMI Config from saved settings or defaults
  final amiHost = prefs.getString('ami_host') ?? AppConfig.defaultAmiHost;
  final amiPort = prefs.getInt('ami_port') ?? AppConfig.defaultAmiPort;
  final amiUsername = prefs.getString('ami_username') ?? AppConfig.defaultAmiUsername;
  final amiPassword = await secureStorage.read(key: 'ami_password') ?? AppConfig.defaultAmiSecret;

  // SSH Config & Manager
  sl.registerLazySingleton<SshConfig>(
    () => SshConfig(
      host: sshHost,
      port: sshPort,
      username: sshUsername,
      authMethod: 'password',
      password: sshPassword,
    ),
  );
  
  sl.registerLazySingleton<AsteriskSshManager>(
    () => AsteriskSshManager(sl<SshConfig>()),
  );

  // AMI Listen Client
  sl.registerLazySingleton<AmiListenClient>(
    () => AmiListenClient(
      host: amiHost,
      port: amiPort,
      username: amiUsername,
      secret: amiPassword,
    ),
  );

  // Data layer
  sl.registerFactory(
    () => AmiDataSource(
      host: amiHost,
      port: amiPort,
      username: amiUsername,
      secret: amiPassword,
    ),
  );
  
  sl.registerFactory<SshCdrDataSource>(
    () => SshCdrDataSource(sshManager: sl<AsteriskSshManager>()),
  );
  
  sl.registerFactory<SshSystemDataSource>(
    () => SshSystemDataSource(sshManager: sl<AsteriskSshManager>()),
  );

  // Repositories با شرط
  if (useMock) {
    sl.registerLazySingleton<IExtensionRepository>(
      () => ExtensionRepositoryMock(),
    );
    sl.registerLazySingleton<IMonitorRepository>(
      () => MonitorRepositoryMock(),
    );
    sl.registerLazySingleton<ICdrRepository>(
      () => CdrRepositoryMock(),
    );
  } else {
    sl.registerLazySingleton<IExtensionRepository>(
      () => ExtensionRepositoryImpl(sl<AmiDataSource>()),
    );
    sl.registerLazySingleton<IMonitorRepository>(
      () => MonitorRepositoryImpl(sl<AmiDataSource>()),
    );
    sl.registerLazySingleton<ICdrRepository>(
      () => CdrRepositoryImpl(sl<SshCdrDataSource>()),
    );
  }

  // Domain layer
  sl.registerFactory(() => GetExtensionsUseCase(sl<IExtensionRepository>()));
  sl.registerFactory(() => PauseAgentUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => UnpauseAgentUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => GetQueueStatusUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => GetAgentDetailsUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => GetCdrRecordsUseCase(sl<ICdrRepository>()));
  sl.registerFactory(() => ExportCdrToCsvUseCase());
  sl.registerFactory(() => GetTrunksUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => GetParkedCallsUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => GetDashboardStatsUseCase(sl<IExtensionRepository>(), sl<IMonitorRepository>()));
  sl.registerFactory(() => GetActiveCallsUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => HangupCallUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => TransferCallUseCase(sl<IMonitorRepository>()));
  sl.registerFactory(() => OriginateCallUseCase(sl<IMonitorRepository>()));

  // Presentation layer
  sl.registerFactory(() => ExtensionBloc(sl<GetExtensionsUseCase>()));
  sl.registerFactory(
    () => QueueBloc(
      getQueueStatusUseCase: sl<GetQueueStatusUseCase>(),
      pauseAgentUseCase: sl<PauseAgentUseCase>(),
      unpauseAgentUseCase: sl<UnpauseAgentUseCase>(),
    ),
  );
  sl.registerFactory(
    () => AgentDetailBloc(
      getAgentDetailsUseCase: sl<GetAgentDetailsUseCase>(),
      pauseAgentUseCase: sl<PauseAgentUseCase>(),
      unpauseAgentUseCase: sl<UnpauseAgentUseCase>(),
    ),
  );
  sl.registerFactory(
    () => CdrBloc(
      getCdrRecordsUseCase: sl<GetCdrRecordsUseCase>(),
      exportCdrToCsvUseCase: sl<ExportCdrToCsvUseCase>(),
    ),
  );
  sl.registerFactory(() => TrunkBloc(getTrunksUseCase: sl<GetTrunksUseCase>()));
  sl.registerFactory(
    () => ParkingBloc(getParkedCallsUseCase: sl<GetParkedCallsUseCase>()),
  );
  sl.registerFactory(
    () => DashboardBloc(sl<GetDashboardStatsUseCase>(), sl<GetActiveCallsUseCase>()),
  );
  sl.registerFactory(
    () => ActiveCallBloc(sl<GetActiveCallsUseCase>(), sl<HangupCallUseCase>(), sl<TransferCallUseCase>()),
  );
}
