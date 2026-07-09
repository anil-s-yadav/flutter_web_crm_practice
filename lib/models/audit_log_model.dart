import 'package:practice_app/models/user_model.dart';

enum ActionType {
  create,
  update,
  delete,
  statusChange,
  paymentLogged,
  contractRenewed,
  slaInitiated,
  taskCompleted
}

class AuditLogModel {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final UserRole userRole;
  final ActionType actionType;
  final String targetId;
  final String description;

  const AuditLogModel({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.actionType,
    required this.targetId,
    required this.description,
  });
}
