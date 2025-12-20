part of 'cdr_bloc.dart';

abstract class CdrEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCdrRecords extends CdrEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? src;
  final String? dst;
  final String? disposition;
  final int limit;

  LoadCdrRecords({
    this.startDate,
    this.endDate,
    this.src,
    this.dst,
    this.disposition,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [startDate, endDate, src, dst, disposition, limit];
}

class FilterCdrRecords extends CdrEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? src;
  final String? dst;
  final String? disposition;
  final int limit;

  FilterCdrRecords({
    this.startDate,
    this.endDate,
    this.src,
    this.dst,
    this.disposition,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [startDate, endDate, src, dst, disposition, limit];
}

class ExportCdrRecords extends CdrEvent {
  final List<CdrRecord> records;

  ExportCdrRecords(this.records);

  @override
  List<Object?> get props => [records];
}
