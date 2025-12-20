part of 'cdr_bloc.dart';

sealed class CdrEvent {}

final class LoadCdrRecords extends CdrEvent {
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
}

final class FilterCdrRecords extends CdrEvent {
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
}

final class ExportCdrRecords extends CdrEvent {
  final List<CdrRecord> records;

  ExportCdrRecords(this.records);
}
