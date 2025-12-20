import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../core/notification_service.dart';
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
      try {
        final queues = await getQueueStatusUseCase();
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
      } catch (e) {
        logger.e('Queue load error: $e');
        emit(QueueError(e.toString()));
      }
    });

    on<PauseAgent>((event, emit) async {
      try {
        await pauseAgentUseCase(
          queue: event.queue,
          interface: event.interface,
          reason: event.reason,
        );
        logger.i('Agent paused: ${event.interface} in ${event.queue}');
        // Reload queues to refresh the UI
        add(LoadQueues());
      } catch (e) {
        logger.e('Pause agent error: $e');
        emit(QueueError(e.toString()));
      }
    });

    on<UnpauseAgent>((event, emit) async {
      try {
        await unpauseAgentUseCase(
          queue: event.queue,
          interface: event.interface,
        );
        logger.i('Agent unpaused: ${event.interface} in ${event.queue}');
        // Reload queues to refresh the UI
        add(LoadQueues());
      } catch (e) {
        logger.e('Unpause agent error: $e');
        emit(QueueError(e.toString()));
      }
    });
  }
}
