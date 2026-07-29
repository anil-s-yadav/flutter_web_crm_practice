import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  final String? role;
  const LoadUsers({this.role});

  @override
  List<Object?> get props => [role];
}

class CreateCrmUser extends UserEvent {
  final Map<String, dynamic> userData;
  const CreateCrmUser(this.userData);

  @override
  List<Object?> get props => [userData];
}

class UpdateCrmUser extends UserEvent {
  final String id;
  final Map<String, dynamic> userData;
  const UpdateCrmUser({required this.id, required this.userData});

  @override
  List<Object?> get props => [id, userData];
}
