import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/extension.dart';
import '../../core/result.dart';
import '../../domain/usecases/get_extensions_usecase.dart';

part 'extension_event.dart';
part 'extension_state.dart';

class ExtensionBloc extends Bloc<ExtensionEvent, ExtensionState> {
  final GetExtensionsUseCase getExtensionsUseCase;
  final Logger logger = Logger();

  ExtensionBloc(this.getExtensionsUseCase) : super(const ExtensionInitial()) {
    on<LoadExtensions>((event, emit) async {
      logger.i('Emitting ExtensionLoading');
      emit(const ExtensionLoading());
      final result = await getExtensionsUseCase();
      switch (result) {
        case Success(:final data):
          // Sort: Online first, then by Name
          data.sort((a, b) {
            if (a.isOnline && !b.isOnline) return -1;
            if (!a.isOnline && b.isOnline) return 1;
            return a.name.compareTo(b.name);
          });
          logger.i('Received ${data.length} extensions, emitting ExtensionLoaded');
          emit(ExtensionLoaded(data));
        case Failure(:final message):
          logger.e('Error in Bloc: $message');
          emit(ExtensionError(message));
      }
    });
  }
}