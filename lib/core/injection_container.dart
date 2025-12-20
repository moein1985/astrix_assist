import 'package:get_it/get_it.dart';
import '../domain/usecases/get_extensions_usecase.dart';
import '../domain/usecases/pause_agent_usecase.dart';
import '../domain/usecases/unpause_agent_usecase.dart';
import '../domain/usecases/get_queue_status_usecase.dart';
import '../domain/usecases/get_agent_details_usecase.dart';
import '../domain/usecases/get_cdr_records_usecase.dart';
import '../domain/usecases/export_cdr_to_csv_usecase.dart';
import '../domain/usecases/get_trunks_usecase.dart';
import '../domain/usecases/get_parked_calls_usecase.dart';
import '../data/datasources/ami_datasource.dart';
import '../data/datasources/cdr_datasource.dart';
import '../data/repositories/extension_repository_impl.dart';
import '../data/repositories/monitor_repository_impl.dart';
import '../data/repositories/cdr_repository_impl.dart';
import '../presentation/blocs/extension_bloc.dart';
import '../presentation/blocs/queue_bloc.dart';
import '../presentation/blocs/agent_detail_bloc.dart';
import '../presentation/blocs/cdr_bloc.dart';
import '../presentation/blocs/trunk_bloc.dart';
import '../presentation/blocs/parking_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Data layer
  sl.registerFactory(
    () => AmiDataSource(
      host: '192.168.85.88', // Default, will be overridden
      port: 5038,
      username: 'moein_api',
      secret: '123456',
    ),
  );
  sl.registerFactory(
    () => CdrDataSource(
      host: '192.168.85.88',
      port: 3306,
      user: 'root',
      password: '',
      db: 'asteriskcdrdb',
    ),
  );
  sl.registerFactory(() => ExtensionRepositoryImpl(sl<AmiDataSource>()));
  sl.registerFactory(() => MonitorRepositoryImpl(sl<AmiDataSource>()));
  sl.registerFactory(() => CdrRepositoryImpl(sl<CdrDataSource>()));

  // Domain layer
  sl.registerFactory(() => GetExtensionsUseCase(sl<ExtensionRepositoryImpl>()));
  sl.registerFactory(() => PauseAgentUseCase(sl<MonitorRepositoryImpl>()));
  sl.registerFactory(() => UnpauseAgentUseCase(sl<MonitorRepositoryImpl>()));
  sl.registerFactory(() => GetQueueStatusUseCase(sl<MonitorRepositoryImpl>()));
  sl.registerFactory(() => GetAgentDetailsUseCase(sl<MonitorRepositoryImpl>()));
  sl.registerFactory(() => GetCdrRecordsUseCase(sl<CdrRepositoryImpl>()));
  sl.registerFactory(() => ExportCdrToCsvUseCase());
  sl.registerFactory(() => GetTrunksUseCase(sl<MonitorRepositoryImpl>()));
  sl.registerFactory(() => GetParkedCallsUseCase(sl<MonitorRepositoryImpl>()));

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
}
