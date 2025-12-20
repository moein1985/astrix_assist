import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/cdr_record.dart';
import '../../domain/usecases/get_cdr_records_usecase.dart';
import '../../domain/usecases/export_cdr_to_csv_usecase.dart';

part 'cdr_event.dart';
part 'cdr_state.dart';

class CdrBloc extends Bloc<CdrEvent, CdrState> {
  final GetCdrRecordsUseCase getCdrRecordsUseCase;
  final ExportCdrToCsvUseCase exportCdrToCsvUseCase;
  final Logger logger = Logger();

  CdrBloc({
    required this.getCdrRecordsUseCase,
    required this.exportCdrToCsvUseCase,
  }) : super(CdrInitial()) {
    on<LoadCdrRecords>((event, emit) async {
      emit(CdrLoading());
      try {
        final records = await getCdrRecordsUseCase(
          startDate: event.startDate,
          endDate: event.endDate,
          src: event.src,
          dst: event.dst,
          disposition: event.disposition,
          limit: event.limit,
        );
        logger.i('Loaded ${records.length} CDR records');
        emit(CdrLoaded(records));
      } catch (e) {
        logger.e('CDR load error: $e');
        emit(CdrError(e.toString()));
      }
    });

    on<FilterCdrRecords>((event, emit) async {
      emit(CdrLoading());
      try {
        final records = await getCdrRecordsUseCase(
          startDate: event.startDate,
          endDate: event.endDate,
          src: event.src,
          dst: event.dst,
          disposition: event.disposition,
          limit: event.limit,
        );
        logger.i('Filtered ${records.length} CDR records');
        emit(CdrLoaded(records));
      } catch (e) {
        logger.e('CDR filter error: $e');
        emit(CdrError(e.toString()));
      }
    });

    on<ExportCdrRecords>((event, emit) async {
      emit(CdrExporting());
      try {
        final filePath = await exportCdrToCsvUseCase(event.records);
        logger.i('Exported ${event.records.length} CDR records to $filePath');
        emit(CdrExported(filePath));
      } catch (e) {
        logger.e('CDR export error: $e');
        emit(CdrExportError(e.toString()));
      }
    });
  }
}
