import 'package:equatable/equatable.dart';
import 'package:practice_app/models/crm_user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<CrmUserModel> users;

  const UserLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
