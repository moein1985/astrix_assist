import '../entities/extension.dart';
import '../repositories/iextension_repository.dart';
import '../../core/result.dart';

class GetExtensionsUseCase {
  final IExtensionRepository repository;

  GetExtensionsUseCase(this.repository);

  Future<Result<List<Extension>>> call() async {
    return await repository.getExtensions();
  }
}