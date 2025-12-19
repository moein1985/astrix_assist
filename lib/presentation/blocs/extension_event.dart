part of 'extension_bloc.dart';

abstract class ExtensionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadExtensions extends ExtensionEvent {}