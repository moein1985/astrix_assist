part of 'extension_bloc.dart';

sealed class ExtensionState {
  const ExtensionState();
}

final class ExtensionInitial extends ExtensionState {
  const ExtensionInitial();
}

final class ExtensionLoading extends ExtensionState {
  const ExtensionLoading();
}

final class ExtensionLoaded extends ExtensionState {
  final List<Extension> extensions;

  const ExtensionLoaded(this.extensions);
}

final class ExtensionError extends ExtensionState {
  final String message;

  const ExtensionError(this.message);
}