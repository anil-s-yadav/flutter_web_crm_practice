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
  final String? candidateId;
  final String? candidateName;
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
    this.candidateId,
    this.candidateName,
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: TicketPriorityExtension.fromString(json['priority']?.toString() ?? 'standard'),
      status: TicketStatusExtension.fromString(json['status']?.toString() ?? 'open'),
      clientId: json['client_id']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? 'Unknown Client',
      candidateId: json['candidate_id']?.toString(),
      candidateName: json['candidateName']?.toString(),
      contractId: json['contract_id']?.toString(),
      assignedTo: json['assigned_to']?.toString() ?? 'Unassigned',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'].toString())
          : null,
      slaDeadline: json['sla_deadline'] != null
          ? DateTime.parse(json['sla_deadline'].toString())
          : null,
      resolution: json['resolution']?.toString()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'client_id': clientId,
      'clientName': clientName,
      'candidate_id': candidateId,
      'candidateName': candidateName,
      'contract_id': contractId,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'sla_deadline': slaDeadline?.toIso8601String(),
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
    String? candidateId,
    String? candidateName,
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
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
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
