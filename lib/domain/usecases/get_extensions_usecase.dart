import '../entities/extension.dart';
import '../repositories/iextension_repository.dart';

class GetExtensionsUseCase {
  final IExtensionRepository repository;

  GetExtensionsUseCase(this.repository);

  Future<List<Extension>> call() async {
    return await repository.getExtensions();
  }
}