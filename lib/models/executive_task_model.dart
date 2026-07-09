import 'dart:convert';

enum TaskType { maidDrop, paymentCollection, documentPickup, clientVisit }

enum TaskStatus { pending, inProgress, completed, cancelled }

extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.maidDrop:
        return 'Maid Drop';
      case TaskType.paymentCollection:
        return 'Payment Collection';
      case TaskType.documentPickup:
        return 'Document Pickup';
      case TaskType.clientVisit:
        return 'Client Visit';
    }
  }

  static TaskType fromString(String value) {
    return TaskType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskType.clientVisit
    );
  }
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.pending
    );
  }
}

class ExecutiveTaskModel {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskStatus status;
  final String assignedTo;
  final String clientName;
  final String clientAddress;
  final String clientPhone;
  final String? maidName;
  final String? maidPhone;
  final String? gpsLink;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final bool isPaymentCollected;
  final double? paymentAmount;
  final String? remarks;

  const ExecutiveTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.assignedTo,
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    this.maidName,
    this.maidPhone,
    this.gpsLink,
    required this.scheduledDate,
    this.completedAt,
    this.isPaymentCollected = false,
    this.paymentAmount,
    this.remarks
  });

  factory ExecutiveTaskModel.fromJson(Map<String, dynamic> json) {
    return ExecutiveTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: TaskTypeExtension.fromString(json['type'] as String),
      status: TaskStatusExtension.fromString(json['status'] as String),
      assignedTo: json['assignedTo'] as String,
      clientName: json['clientName'] as String,
      clientAddress: json['clientAddress'] as String,
      clientPhone: json['clientPhone'] as String,
      maidName: json['maidName'] as String?,
      maidPhone: json['maidPhone'] as String?,
      gpsLink: json['gpsLink'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isPaymentCollected: (json['isPaymentCollected'] as bool?) ?? false,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
      remarks: json['remarks'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'assignedTo': assignedTo,
      'clientName': clientName,
      'clientAddress': clientAddress,
      'clientPhone': clientPhone,
      'maidName': maidName,
      'maidPhone': maidPhone,
      'gpsLink': gpsLink,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isPaymentCollected': isPaymentCollected,
      'paymentAmount': paymentAmount,
      'remarks': remarks
    };
  }

  String toJsonString() => jsonEncode(toJson());

  ExecutiveTaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskStatus? status,
    String? assignedTo,
    String? clientName,
    String? clientAddress,
    String? clientPhone,
    String? maidName,
    String? maidPhone,
    String? gpsLink,
    DateTime? scheduledDate,
    DateTime? completedAt,
    bool? isPaymentCollected,
    double? paymentAmount,
    String? remarks
  }) {
    return ExecutiveTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
      clientPhone: clientPhone ?? this.clientPhone,
      maidName: maidName ?? this.maidName,
      maidPhone: maidPhone ?? this.maidPhone,
      gpsLink: gpsLink ?? this.gpsLink,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      isPaymentCollected: isPaymentCollected ?? this.isPaymentCollected,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      remarks: remarks ?? this.remarks
    );
  }

  @override
  String toString() => 'ExecutiveTaskModel(id: $id, title: $title, type: ${type.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutiveTaskModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
