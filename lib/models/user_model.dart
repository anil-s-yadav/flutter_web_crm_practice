import 'dart:convert';

enum UserRole { admin, sales, sourcing, executive }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.sales:
        return 'Sales';
      case UserRole.sourcing:
        return 'Sourcing';
      case UserRole.executive:
        return 'Executive';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.sales
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRoleExtension.fromString(json['role'] as String),
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?
    );
  }

  factory UserModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'avatarUrl': avatarUrl
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? avatarUrl
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: ${role.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
