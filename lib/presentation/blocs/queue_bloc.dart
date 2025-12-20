import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import '../../core/notification_service.dart';
import '../../core/result.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/usecases/get_queue_status_usecase.dart';
import '../../domain/usecases/pause_agent_usecase.dart';
import '../../domain/usecases/unpause_agent_usecase.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueStatusUseCase getQueueStatusUseCase;
  final PauseAgentUseCase pauseAgentUseCase;
  final UnpauseAgentUseCase unpauseAgentUseCase;
  final Logger logger = Logger();

  QueueBloc({
    required this.getQueueStatusUseCase,
    required this.pauseAgentUseCase,
    required this.unpauseAgentUseCase,
  }) : super(QueueInitial()) {
    on<LoadQueues>((event, emit) async {
      emit(QueueLoading());
      final result = await getQueueStatusUseCase();
      switch (result) {
        case Success(:final data):
          final queues = data;
          logger.i('Loaded ${queues.length} queues');

          // Check for queue overflow and send notifications
          for (final queue in queues) {
            if (queue.calls > 5) {
              await NotificationService().showQueueOverflowNotification(
                queueName: queue.queue,
                waitingCalls: queue.calls,
              );
            }
          }

          emit(QueueLoaded(queues));
        case Failure(:final message):
          logger.e('Queue load error: $message');
          emit(QueueError(message));
      }
    });

    on<PauseAgent>((event, emit) async {
      final result = await pauseAgentUseCase(
        queue: event.queue,
        interface: event.interface,
        reason: event.reason,
      );
      switch (result) {
        case Success():
          logger.i('Agent paused: ${event.interface} in ${event.queue}');
          // Reload queues to refresh the UI
          add(const LoadQueues());
        case Failure(:final message):
          logger.e('Pause agent error: $message');
          emit(QueueError(message));
      }
    });

    on<UnpauseAgent>((event, emit) async {
      final result = await unpauseAgentUseCase(
        queue: event.queue,
        interface: event.interface,
      );
      switch (result) {
        case Success():
          logger.i('Agent unpaused: ${event.interface} in ${event.queue}');
          // Reload queues to refresh the UI
          add(const LoadQueues());
        case Failure(:final message):
          logger.e('Unpause agent error: $message');
          emit(QueueError(message));
      }
    });
  }
}
