import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/extension.dart';
import '../../domain/usecases/get_extensions_usecase.dart';

part 'extension_event.dart';
part 'extension_state.dart';

class ExtensionBloc extends Bloc<ExtensionEvent, ExtensionState> {
  final GetExtensionsUseCase getExtensionsUseCase;
  final Logger logger = Logger();

  ExtensionBloc(this.getExtensionsUseCase) : super(ExtensionInitial()) {
    on<LoadExtensions>((event, emit) async {
      logger.i('Emitting ExtensionLoading');
      emit(ExtensionLoading());
      try {
        logger.i('Calling getExtensionsUseCase');
        final extensions = await getExtensionsUseCase();
        
        // Sort: Online first, then by Name
        extensions.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return a.name.compareTo(b.name);
        });

        logger.i('Received ${extensions.length} extensions, emitting ExtensionLoaded');
        emit(ExtensionLoaded(extensions));
      } catch (e) {
        logger.e('Error in Bloc: $e');
        emit(ExtensionError(e.toString()));
      }
    });
  }
}