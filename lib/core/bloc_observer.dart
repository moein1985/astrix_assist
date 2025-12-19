import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

class MyBlocObserver extends BlocObserver {
  final Logger logger = Logger();

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.i('Bloc: ${bloc.runtimeType}, Event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.i('Bloc: ${bloc.runtimeType}, Transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e('Bloc: ${bloc.runtimeType}, Error: $error', error: error, stackTrace: stackTrace);
  }
}