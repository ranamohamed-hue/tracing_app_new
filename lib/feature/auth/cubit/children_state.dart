import 'package:equatable/equatable.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';

abstract class ChildrenState extends Equatable {
  const ChildrenState();
  
  @override
  List<Object> get props => [];
}

class ChildrenInitial extends ChildrenState {}

class ChildrenLoadingState extends ChildrenState {}

class ChildrenLoadedState extends ChildrenState {
  final List<UserModel> children;
  const ChildrenLoadedState(this.children);

  @override
  List<Object> get props => [children];
}

class ChildrenErrorState extends ChildrenState {
  final String message;
  const ChildrenErrorState(this.message);

  @override
  List<Object> get props => [message];
}