part of 'extension_bloc.dart';

abstract class ExtensionState extends Equatable {
  @override
  List<Object> get props => [];
}

class ExtensionInitial extends ExtensionState {}

class ExtensionLoading extends ExtensionState {}

class ExtensionLoaded extends ExtensionState {
  final List<Extension> extensions;

  ExtensionLoaded(this.extensions);

  @override
  List<Object> get props => [extensions];
}

class ExtensionError extends ExtensionState {
  final String message;

  ExtensionError(this.message);

  @override
  List<Object> get props => [message];
}