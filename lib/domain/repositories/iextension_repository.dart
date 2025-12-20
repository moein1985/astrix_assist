import '../../domain/entities/extension.dart';
import '../../core/result.dart';

abstract class IExtensionRepository {
  Future<Result<List<Extension>>> getExtensions();
}