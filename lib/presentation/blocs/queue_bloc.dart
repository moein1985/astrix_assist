import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/usecases/get_queue_status_usecase.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueStatusUseCase getQueueStatusUseCase;
  final Logger logger = Logger();

  QueueBloc(this.getQueueStatusUseCase) : super(QueueInitial()) {
    on<LoadQueues>((event, emit) async {
      emit(QueueLoading());
      try {
        final queues = await getQueueStatusUseCase();
        logger.i('Loaded ${queues.length} queues');
        emit(QueueLoaded(queues));
      } catch (e) {
        logger.e('Queue load error: $e');
        emit(QueueError(e.toString()));
      }
    });
  }
}
