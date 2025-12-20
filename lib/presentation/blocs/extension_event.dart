part of 'extension_bloc.dart';

sealed class ExtensionEvent {
  const ExtensionEvent();
}

final class LoadExtensions extends ExtensionEvent {
  const LoadExtensions();
}