import 'dart:convert';

enum TicketPriority { critical, urgent, standard }

enum TicketStatus { open, inProgress, resolved, closed }

extension TicketPriorityExtension on TicketPriority {
  String get displayName {
    switch (this) {
      case TicketPriority.critical:
        return 'Critical';
      case TicketPriority.urgent:
        return 'Urgent';
      case TicketPriority.standard:
        return 'Standard';
    }
  }

  String get colorHex {
    switch (this) {
      case TicketPriority.critical:
        return '#E53935'; // Red
      case TicketPriority.urgent:
        return '#FDD835'; // Yellow
      case TicketPriority.standard:
        return '#1E88E5'; // Blue
    }
  }

  static TicketPriority fromString(String value) {
    return TicketPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketPriority.standard
    );
  }
}

extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  static TicketStatus fromString(String value) {
    return TicketStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketStatus.open
    );
  }
}

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketPriority priority;
  final TicketStatus status;
  final String clientId;
  final String clientName;
  final String? maidId;
  final String? maidName;
  final String? contractId;
  final String assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? slaDeadline;
  final String? resolution;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.clientId,
    required this.clientName,
    this.maidId,
    this.maidName,
    this.contractId,
    required this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
    this.slaDeadline,
    this.resolution
  });

  bool get isSlaBreached {
    if (slaDeadline == null) return false;
    if (status == TicketStatus.resolved || status == TicketStatus.closed) return false;
    return DateTime.now().isAfter(slaDeadline!);
  }

  int get daysUntilSla {
    if (slaDeadline == null) return -1;
    final now = DateTime.now();
    if (now.isAfter(slaDeadline!)) return 0;
    return slaDeadline!.difference(now).inDays;
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: TicketPriorityExtension.fromString(json['priority'] as String),
      status: TicketStatusExtension.fromString(json['status'] as String),
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      maidId: json['maidId'] as String?,
      maidName: json['maidName'] as String?,
      contractId: json['contractId'] as String?,
      assignedTo: json['assignedTo'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      slaDeadline: json['slaDeadline'] != null
          ? DateTime.parse(json['slaDeadline'] as String)
          : null,
      resolution: json['resolution'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'clientId': clientId,
      'clientName': clientName,
      'maidId': maidId,
      'maidName': maidName,
      'contractId': contractId,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'slaDeadline': slaDeadline?.toIso8601String(),
      'resolution': resolution
    };
  }

  String toJsonString() => jsonEncode(toJson());

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    TicketPriority? priority,
    TicketStatus? status,
    String? clientId,
    String? clientName,
    String? maidId,
    String? maidName,
    String? contractId,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? resolvedAt,
    DateTime? slaDeadline,
    String? resolution
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      maidId: maidId ?? this.maidId,
      maidName: maidName ?? this.maidName,
      contractId: contractId ?? this.contractId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      slaDeadline: slaDeadline ?? this.slaDeadline,
      resolution: resolution ?? this.resolution
    );
  }

  @override
  String toString() => 'TicketModel(id: $id, title: $title, priority: ${priority.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
