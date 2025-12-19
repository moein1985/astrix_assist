import 'package:get_it/get_it.dart';
import '../domain/usecases/get_extensions_usecase.dart';
import '../data/datasources/ami_datasource.dart';
import '../data/repositories/extension_repository_impl.dart';
import '../presentation/blocs/extension_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Data layer
  sl.registerFactory(() => AmiDataSource(
        host: '192.168.85.88', // Default, will be overridden
        port: 5038,
        username: 'moein_api',
        secret: '123456',
      ));
  sl.registerFactory(() => ExtensionRepositoryImpl(sl<AmiDataSource>()));

  // Domain layer
  sl.registerFactory(() => GetExtensionsUseCase(sl<ExtensionRepositoryImpl>()));

  // Presentation layer
  sl.registerFactory(() => ExtensionBloc(sl<GetExtensionsUseCase>()));
}