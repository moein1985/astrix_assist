import '../../domain/entities/extension.dart';

abstract class IExtensionRepository {
  Future<List<Extension>> getExtensions();
}