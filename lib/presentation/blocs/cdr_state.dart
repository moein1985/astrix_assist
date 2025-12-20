part of 'cdr_bloc.dart';

abstract class CdrState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CdrInitial extends CdrState {}

class CdrLoading extends CdrState {}

class CdrLoaded extends CdrState {
  final List<CdrRecord> records;

  CdrLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class CdrError extends CdrState {
  final String message;

  CdrError(this.message);

  @override
  List<Object?> get props => [message];
}

class CdrExporting extends CdrState {}

class CdrExported extends CdrState {
  final String filePath;

  CdrExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class CdrExportError extends CdrState {
  final String message;

  CdrExportError(this.message);

  @override
  List<Object?> get props => [message];
}
