import 'package:logger/logger.dart';
import '../../domain/entities/extension.dart';
import '../../domain/repositories/iextension_repository.dart';
import '../datasources/ami_datasource.dart';
import '../models/extension_model.dart';

class ExtensionRepositoryImpl implements IExtensionRepository {
  final AmiDataSource dataSource;
  final Logger logger = Logger(level: Level.warning);

  ExtensionRepositoryImpl(this.dataSource);

  @override
  Future<List<Extension>> getExtensions() async {
    logger.d('Connecting to AMI');
    await dataSource.connect();
    logger.d('Logging in');
    final loginResult = await dataSource.login();
    if (loginResult != 'success') throw Exception('Login failed');
    logger.d('Getting queue status (SIPpeers)');
    final events = await dataSource.getQueueStatus();
    logger.d('Received ${events.length} events');
    dataSource.disconnect();
    final extensions = <Extension>[];
    for (final e in events) {
      try {
        extensions.add(ExtensionModel.fromAmi(e));
      } catch (ex) {
        logger.w('Failed to parse extension: $ex');
      }
    }
    logger.d('Parsed ${extensions.length} extensions');
    return extensions;
  }
}