import 'package:equatable/equatable.dart';

abstract class ParentState extends Equatable {
  const ParentState();
  
  @override
  List<Object> get props => [];
}

class ParentInitial extends ParentState {}

class InviteCodeLoadingState extends ParentState {}

class InviteCodeGeneratedState extends ParentState {
  final String code;
  const InviteCodeGeneratedState(this.code);

  @override
  List<Object> get props => [code];
}

class InviteCodeErrorState extends ParentState {
  final String error;
  const InviteCodeErrorState(this.error);

  @override
  List<Object> get props => [error];
}

class LinkingLoadingState extends ParentState {}

class LinkingSuccessState extends ParentState {}

class LinkingErrorState extends ParentState {
  final String message;
  const LinkingErrorState(this.message);

  @override
  List<Object> get props => [message];
}