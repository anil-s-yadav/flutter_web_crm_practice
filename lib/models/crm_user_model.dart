import 'package:practice_app/models/user_model.dart';

enum CrmUserStatus { active, inactive, suspended }

extension CrmUserStatusExtension on CrmUserStatus {
  String get displayName {
    switch (this) {
      case CrmUserStatus.active:
        return 'Active';
      case CrmUserStatus.inactive:
        return 'Inactive';
      case CrmUserStatus.suspended:
        return 'Suspended';
    }
  }
}

class CrmUserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final CrmUserStatus status;
  final DateTime joinedDate;
  final DateTime? lastLogin;
  final String password; // stored as plain text for mock purposes
  final int candidatesAdded;
  final int clientsConverted;
  final int contractsClosed;

  const CrmUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.status = CrmUserStatus.active,
    required this.joinedDate,
    this.lastLogin,
    this.password = 'password123',
    this.candidatesAdded = 0,
    this.clientsConverted = 0,
    this.contractsClosed = 0,
  });

  CrmUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    CrmUserStatus? status,
    DateTime? joinedDate,
    DateTime? lastLogin,
    String? password,
    int? candidatesAdded,
    int? clientsConverted,
    int? contractsClosed,
  }) {
    return CrmUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      lastLogin: lastLogin ?? this.lastLogin,
      password: password ?? this.password,
      candidatesAdded: candidatesAdded ?? this.candidatesAdded,
      clientsConverted: clientsConverted ?? this.clientsConverted,
      contractsClosed: contractsClosed ?? this.contractsClosed,
    );
  }
}
