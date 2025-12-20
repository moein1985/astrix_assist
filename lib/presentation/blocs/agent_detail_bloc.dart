import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/agent_details.dart';
import '../../domain/usecases/get_agent_details_usecase.dart';
import '../../domain/usecases/pause_agent_usecase.dart';
import '../../domain/usecases/unpause_agent_usecase.dart';

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
      try {
        final details = await getAgentDetailsUseCase(event.agentInterface);
        logger.i('Loaded agent details: ${details.name}');
        emit(AgentDetailLoaded(details));
      } catch (e) {
        logger.e('Agent detail load error: $e');
        emit(AgentDetailError(e.toString()));
      }
    });

    on<PauseAgentFromDetail>((event, emit) async {
      if (state is AgentDetailLoaded) {
        final currentDetails = (state as AgentDetailLoaded).details;
        try {
          await pauseAgentUseCase(
            queue: event.queue,
            interface: event.interface,
            reason: event.reason,
          );
          logger.i('Agent paused from detail: ${event.interface}');
          // Reload details
          add(LoadAgentDetails(event.interface));
        } catch (e) {
          logger.e('Pause agent error: $e');
          emit(AgentDetailError(e.toString()));
          // Restore previous state
          emit(AgentDetailLoaded(currentDetails));
        }
      }
    });

    on<UnpauseAgentFromDetail>((event, emit) async {
      if (state is AgentDetailLoaded) {
        final currentDetails = (state as AgentDetailLoaded).details;
        try {
          await unpauseAgentUseCase(
            queue: event.queue,
            interface: event.interface,
          );
          logger.i('Agent unpaused from detail: ${event.interface}');
          // Reload details
          add(LoadAgentDetails(event.interface));
        } catch (e) {
          logger.e('Unpause agent error: $e');
          emit(AgentDetailError(e.toString()));
          // Restore previous state
          emit(AgentDetailLoaded(currentDetails));
        }
      }
    });
  }
}
