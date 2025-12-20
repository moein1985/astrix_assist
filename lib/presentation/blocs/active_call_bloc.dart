import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/active_call.dart';
import '../../domain/usecases/get_active_calls_usecase.dart';
import '../../domain/usecases/hangup_call_usecase.dart';
import '../../domain/usecases/transfer_call_usecase.dart';

part 'active_call_event.dart';
part 'active_call_state.dart';

class ActiveCallBloc extends Bloc<ActiveCallEvent, ActiveCallState> {
  final GetActiveCallsUseCase getActiveCallsUseCase;
  final HangupCallUseCase hangupCallUseCase;
  final TransferCallUseCase transferCallUseCase;
  final Logger logger = Logger();

  ActiveCallBloc(
    this.getActiveCallsUseCase,
    this.hangupCallUseCase,
    this.transferCallUseCase,
  ) : super(ActiveCallInitial()) {
    on<LoadActiveCalls>((event, emit) async {
      emit(ActiveCallLoading());
      try {
        final calls = await getActiveCallsUseCase();
        logger.i('Loaded ${calls.length} active calls');
        emit(ActiveCallLoaded(calls));
      } catch (e) {
        logger.e('Active call load error: $e');
        emit(ActiveCallError(e.toString()));
      }
    });

    on<HangupCall>((event, emit) async {
      emit(ActiveCallLoading());
      try {
        await hangupCallUseCase(event.channel);
        final calls = await getActiveCallsUseCase();
        emit(ActiveCallLoaded(calls));
      } catch (e) {
        logger.e('Hangup error: $e');
        emit(ActiveCallError(e.toString()));
      }
    });

    on<TransferCall>((event, emit) async {
      emit(ActiveCallLoading());
      try {
        await transferCallUseCase(
          channel: event.channel,
          destination: event.destination,
          context: event.context,
        );
        final calls = await getActiveCallsUseCase();
        emit(ActiveCallLoaded(calls));
      } catch (e) {
        logger.e('Transfer error: $e');
        emit(ActiveCallError(e.toString()));
      }
    });
  }
}
