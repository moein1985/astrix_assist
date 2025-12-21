import 'package:get_it/get_it.dart';
import 'app_config.dart';
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
import '../data/datasources/cdr_datasource.dart';
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

void setupDependencies() {
  // جلوگیری از ثبت مجدد
  if (sl.isRegistered<IExtensionRepository>()) {
    return;
  }
  
  // استفاده از AppConfig برای تعیین Mock یا Real
  const useMock = AppConfig.useMockRepositories;

  // Data layer
  sl.registerFactory(
    () => AmiDataSource(
      host: AppConfig.defaultAmiHost,
      port: AppConfig.defaultAmiPort,
      username: AppConfig.defaultAmiUsername,
      secret: AppConfig.defaultAmiSecret,
    ),
  );
  sl.registerFactory(
    () => CdrDataSource(
      host: AppConfig.defaultDbHost,
      port: AppConfig.defaultDbPort,
      user: AppConfig.defaultDbUser,
      password: AppConfig.defaultDbPassword,
      db: AppConfig.defaultDbName,
    ),
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
      () => CdrRepositoryImpl(sl<CdrDataSource>()),
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
