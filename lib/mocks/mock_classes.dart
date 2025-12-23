import 'package:mocktail/mocktail.dart';

// SSH Mocks
class MockSshService extends Mock {}
class MockSshClient extends Mock {}
class MockSFTPClient extends Mock {}

// AMI Mocks
class MockAmiDataSource extends Mock {}
class MockAmiSocket extends Mock {}

// Repository Mocks
class MockCdrRepository extends Mock {}
class MockExtensionRepository extends Mock {}
class MockMonitorRepository extends Mock {}

// UseCase Mocks
class MockGetCdrRecordsUseCase extends Mock {}
class MockGetExtensionsUseCase extends Mock {}
class MockGetActiveCallsUseCase extends Mock {}
class MockGetQueueStatusUseCase extends Mock {}

// Bloc Mocks
class MockCdrBloc extends Mock {}
class MockExtensionsBloc extends Mock {}
class MockActiveCallsBloc extends Mock {}
class MockQueueBloc extends Mock {}

// Service Mocks
class MockNotificationService extends Mock {}
class MockAudioService extends Mock {}
class MockStorageService extends Mock {}