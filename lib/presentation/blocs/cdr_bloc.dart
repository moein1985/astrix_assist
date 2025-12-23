import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import '../../core/result.dart';
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
      logger.i('📞 LoadCdrRecords event received with: startDate=${event.startDate}, endDate=${event.endDate}, src=${event.src}, dst=${event.dst}, disposition=${event.disposition}, limit=${event.limit}');
      emit(CdrLoading());
      logger.d('⏳ CdrLoading state emitted, calling use case...');
      
      final result = await getCdrRecordsUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
        src: event.src,
        dst: event.dst,
        disposition: event.disposition,
        limit: event.limit,
      );
      
      logger.d('📦 Use case returned result: ${result.runtimeType}');
      switch (result) {
        case Success(:final data):
          final records = data;
          logger.i('✅ Loaded ${records.length} CDR records');
          if (records.isEmpty) {
            logger.w('⚠️ No CDR records found - list is empty');
          } else {
            logger.d('📋 First CDR: ${records.first.callDate} ${records.first.src} -> ${records.first.dst}');
          }
          emit(CdrLoaded(records));
        case Failure(:final message):
          logger.e('❌ CDR load error: $message');
          emit(CdrError(message));
      }
    });

    on<FilterCdrRecords>((event, emit) async {
      logger.i('🔍 FilterCdrRecords event received');
      emit(CdrLoading());
      final result = await getCdrRecordsUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
        src: event.src,
        dst: event.dst,
        disposition: event.disposition,
        limit: event.limit,
      );
      switch (result) {
        case Success(:final data):
          final records = data;
          logger.i('✅ Filtered ${records.length} CDR records');
          emit(CdrLoaded(records));
        case Failure(:final message):
          logger.e('❌ CDR filter error: $message');
          emit(CdrError(message));
      }
    });

    on<ExportCdrRecords>((event, emit) async {
      emit(CdrExporting());
      final result = await exportCdrToCsvUseCase(event.records);
      switch (result) {
        case Success(:final data):
          final filePath = data;
          logger.i('Exported ${event.records.length} CDR records to $filePath');
          emit(CdrExported(filePath));
        case Failure(:final message):
          logger.e('CDR export error: $message');
          emit(CdrExportError(message));
      }
    });
  }
}
