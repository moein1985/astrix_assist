part of 'cdr_bloc.dart';

sealed class CdrState {}

final class CdrInitial extends CdrState {}

final class CdrLoading extends CdrState {}

final class CdrLoaded extends CdrState {
  final List<CdrRecord> records;

  CdrLoaded(this.records);
}

final class CdrError extends CdrState {
  final String message;

  CdrError(this.message);
}

final class CdrExporting extends CdrState {}

final class CdrExported extends CdrState {
  final String filePath;

  CdrExported(this.filePath);
}

final class CdrExportError extends CdrState {
  final String message;

  CdrExportError(this.message);
}
