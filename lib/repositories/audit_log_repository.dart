import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/api/api_client.dart';

class AuditLogRepository {
  final ApiClient apiClient;

  AuditLogRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<List<AuditLogModel>> getAuditLogs() async {
    final response = await ApiClient.get('/api/audit-logs');

    if (response is List) {
      return response.map((json) {
        return AuditLogModel(
          id: json['id'] as String,
          timestamp: DateTime.parse(json['timestamp']),
          userId: json['userId'] as String,
          userName: json['userName'] as String,
          userRole: _parseUserRole(json['userRole'] as String),
          actionType: _parseActionType(json['actionType'] as String),
          targetId: json['targetId'] as String,
          description: json['description'] as String,
        );
      }).toList();
    } else {
      throw Exception('Failed to load audit logs');
    }
  }

  UserRole _parseUserRole(String roleStr) {
    switch (roleStr) {
      case 'admin': return UserRole.admin;
      case 'sales': return UserRole.sales;
      case 'sourcing': return UserRole.sourcing;
      case 'executive': return UserRole.executive;
      default: return UserRole.admin;
    }
  }

  ActionType _parseActionType(String actionStr) {
    switch (actionStr) {
      case 'create': return ActionType.create;
      case 'update': return ActionType.update;
      case 'delete': return ActionType.delete;
      case 'statusChange': return ActionType.statusChange;
      case 'paymentLogged': return ActionType.paymentLogged;
      case 'contractRenewed': return ActionType.contractRenewed;
      case 'slaInitiated': return ActionType.slaInitiated;
      case 'taskCompleted': return ActionType.taskCompleted;
      default: return ActionType.update;
    }
  }
}
