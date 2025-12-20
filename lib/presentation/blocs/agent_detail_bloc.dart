import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/agent_details.dart';
import '../../domain/usecases/get_agent_details_usecase.dart';
import '../../domain/usecases/pause_agent_usecase.dart';
import '../../domain/usecases/unpause_agent_usecase.dart';
import '../../core/result.dart';

part 'agent_detail_event.dart';
part 'agent_detail_state.dart';

class AgentDetailBloc extends Bloc<AgentDetailEvent, AgentDetailState> {
  final GetAgentDetailsUseCase getAgentDetailsUseCase;
  final PauseAgentUseCase pauseAgentUseCase;
  final UnpauseAgentUseCase unpauseAgentUseCase;
  final Logger logger = Logger();

  AgentDetailBloc({
    required this.getAgentDetailsUseCase,
    required this.pauseAgentUseCase,
    required this.unpauseAgentUseCase,
  }) : super(AgentDetailInitial()) {
    on<LoadAgentDetails>((event, emit) async {
      emit(AgentDetailLoading());
      final result = await getAgentDetailsUseCase(event.agentInterface);
      switch (result) {
        case Success(:final data):
          final details = data;
          logger.i('Loaded agent details: ${details.name}');
          emit(AgentDetailLoaded(details));
        case Failure(:final message):
          logger.e('Agent detail load error: $message');
          emit(AgentDetailError(message));
      }
    });

    on<PauseAgentFromDetail>((event, emit) async {
      if (state is AgentDetailLoaded) {
        final currentDetails = (state as AgentDetailLoaded).details;
        final result = await pauseAgentUseCase(
          queue: event.queue,
          interface: event.interface,
          reason: event.reason,
        );
        switch (result) {
          case Success():
            logger.i('Agent paused from detail: ${event.interface}');
            // Reload details
            add(LoadAgentDetails(event.interface));
          case Failure(:final message):
            logger.e('Pause agent error: $message');
            emit(AgentDetailError(message));
            // Restore previous state
            emit(AgentDetailLoaded(currentDetails));
        }
      }
    });

    on<UnpauseAgentFromDetail>((event, emit) async {
      if (state is AgentDetailLoaded) {
        final currentDetails = (state as AgentDetailLoaded).details;
        final result = await unpauseAgentUseCase(
          queue: event.queue,
          interface: event.interface,
        );
        switch (result) {
          case Success():
            logger.i('Agent unpaused from detail: ${event.interface}');
            // Reload details
            add(LoadAgentDetails(event.interface));
          case Failure(:final message):
            logger.e('Unpause agent error: $message');
            emit(AgentDetailError(message));
            // Restore previous state
            emit(AgentDetailLoaded(currentDetails));
        }
      }
    });
  }
}
