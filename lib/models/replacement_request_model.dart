
enum ReplacementStatus { pending, inProgress, resolved }

extension ReplacementStatusExtension on ReplacementStatus {
  String get displayName {
    switch (this) {
      case ReplacementStatus.pending:
        return 'Pending';
      case ReplacementStatus.inProgress:
        return 'In Progress';
      case ReplacementStatus.resolved:
        return 'Resolved';
    }
  }

  static ReplacementStatus fromString(String value) {
    return ReplacementStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReplacementStatus.pending,
    );
  }
}

class ReplacementRequestModel {
  final String id;
  final String contractId;
  final String clientId;
  final String clientName;
  final String oldCandidateId;
  final String oldCandidateName;
  final String? newCandidateId;
  final String reason;
  final ReplacementStatus status;
  final DateTime requestDate;
  final DateTime? resolvedDate;
  final String createdBy;

  // Urgent Sourcing Escalation
  final bool isEscalatedToSourcing;
  final String? requiredCriteria;
  final List<String> suggestedCandidateIds;

  const ReplacementRequestModel({
    required this.id,
    required this.contractId,
    required this.clientId,
    required this.clientName,
    required this.oldCandidateId,
    required this.oldCandidateName,
    this.newCandidateId,
    required this.reason,
    this.status = ReplacementStatus.pending,
    required this.requestDate,
    this.resolvedDate,
    required this.createdBy,
    this.isEscalatedToSourcing = false,
    this.requiredCriteria,
    this.suggestedCandidateIds = const [],
  });

  factory ReplacementRequestModel.fromJson(Map<String, dynamic> json) {
    return ReplacementRequestModel(
      id: json['id'] as String,
      contractId: json['contractId'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      oldCandidateId: json['oldCandidateId'] as String,
      oldCandidateName: json['oldCandidateName'] as String,
      newCandidateId: json['newCandidateId'] as String?,
      reason: json['reason'] as String,
      status: ReplacementStatusExtension.fromString(json['status'] as String),
      requestDate: DateTime.parse(json['requestDate'] as String),
      resolvedDate: json['resolvedDate'] != null
          ? DateTime.parse(json['resolvedDate'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      isEscalatedToSourcing: json['isEscalatedToSourcing'] as bool? ?? false,
      requiredCriteria: json['requiredCriteria'] as String?,
      suggestedCandidateIds: json['suggestedCandidateIds'] != null 
          ? List<String>.from(json['suggestedCandidateIds']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'clientId': clientId,
      'clientName': clientName,
      'oldCandidateId': oldCandidateId,
      'oldCandidateName': oldCandidateName,
      'newCandidateId': newCandidateId,
      'reason': reason,
      'status': status.name,
      'requestDate': requestDate.toIso8601String(),
      'resolvedDate': resolvedDate?.toIso8601String(),
      'createdBy': createdBy,
      'isEscalatedToSourcing': isEscalatedToSourcing,
      'requiredCriteria': requiredCriteria,
      'suggestedCandidateIds': suggestedCandidateIds,
    };
  }

  ReplacementRequestModel copyWith({
    String? id,
    String? contractId,
    String? clientId,
    String? clientName,
    String? oldCandidateId,
    String? oldCandidateName,
    String? newCandidateId,
    String? reason,
    ReplacementStatus? status,
    DateTime? requestDate,
    DateTime? resolvedDate,
    String? createdBy,
    bool? isEscalatedToSourcing,
    String? requiredCriteria,
    List<String>? suggestedCandidateIds,
  }) {
    return ReplacementRequestModel(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      oldCandidateId: oldCandidateId ?? this.oldCandidateId,
      oldCandidateName: oldCandidateName ?? this.oldCandidateName,
      newCandidateId: newCandidateId ?? this.newCandidateId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      createdBy: createdBy ?? this.createdBy,
      isEscalatedToSourcing: isEscalatedToSourcing ?? this.isEscalatedToSourcing,
      requiredCriteria: requiredCriteria ?? this.requiredCriteria,
      suggestedCandidateIds: suggestedCandidateIds ?? this.suggestedCandidateIds,
    );
  }
}
