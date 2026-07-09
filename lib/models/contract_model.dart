import 'dart:convert';

enum PaymentStatus { pending, partial, paid, overdue }

enum ContractStatus { active, completed, replaced, cancelled }

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.pending
    );
  }
}

extension ContractStatusExtension on ContractStatus {
  String get displayName {
    switch (this) {
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.completed:
        return 'Completed';
      case ContractStatus.replaced:
        return 'Replaced';
      case ContractStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContractStatus.active
    );
  }
}

class ContractModel {
  final String id;
  final String clientId;
  final String candidateId;
  final String clientName;
  final String candidateName;
  final DateTime placementDate;
  final DateTime guaranteeEndDate;
  final double serviceFee;
  final double amountPaid;
  final double balanceAmount;
  final PaymentStatus paymentStatus;
  final ContractStatus contractStatus;
  final bool isReplacementUsed;
  final DateTime? replacementDate;
  final String? replacementCandidateId;
  final String createdBy;
  final String? remarks;

  const ContractModel({
    required this.id,
    required this.clientId,
    required this.candidateId,
    required this.clientName,
    required this.candidateName,
    required this.placementDate,
    required this.guaranteeEndDate,
    required this.serviceFee,
    required this.amountPaid,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.contractStatus,
    this.isReplacementUsed = false,
    this.replacementDate,
    this.replacementCandidateId,
    required this.createdBy,
    this.remarks
  });

  int get daysRemainingInGuarantee {
    final now = DateTime.now();
    if (now.isAfter(guaranteeEndDate)) return 0;
    return guaranteeEndDate.difference(now).inDays;
  }

  bool get isGuaranteeActive {
    return DateTime.now().isBefore(guaranteeEndDate);
  }

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      candidateId: json['candidateId'] as String,
      clientName: json['clientName'] as String,
      candidateName: json['candidateName'] as String,
      placementDate: DateTime.parse(json['placementDate'] as String),
      guaranteeEndDate: DateTime.parse(json['guaranteeEndDate'] as String),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      balanceAmount: (json['balanceAmount'] as num).toDouble(),
      paymentStatus: PaymentStatusExtension.fromString(json['paymentStatus'] as String),
      contractStatus: ContractStatusExtension.fromString(json['contractStatus'] as String),
      isReplacementUsed: (json['isReplacementUsed'] as bool?) ?? false,
      replacementDate: json['replacementDate'] != null
          ? DateTime.parse(json['replacementDate'] as String)
          : null,
      replacementCandidateId: json['replacementCandidateId'] as String?,
      createdBy: json['createdBy'] as String,
      remarks: json['remarks'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'candidateId': candidateId,
      'clientName': clientName,
      'candidateName': candidateName,
      'placementDate': placementDate.toIso8601String(),
      'guaranteeEndDate': guaranteeEndDate.toIso8601String(),
      'serviceFee': serviceFee,
      'amountPaid': amountPaid,
      'balanceAmount': balanceAmount,
      'paymentStatus': paymentStatus.name,
      'contractStatus': contractStatus.name,
      'isReplacementUsed': isReplacementUsed,
      'replacementDate': replacementDate?.toIso8601String(),
      'replacementCandidateId': replacementCandidateId,
      'createdBy': createdBy,
      'remarks': remarks
    };
  }

  String toJsonString() => jsonEncode(toJson());

  ContractModel copyWith({
    String? id,
    String? clientId,
    String? candidateId,
    String? clientName,
    String? candidateName,
    DateTime? placementDate,
    DateTime? guaranteeEndDate,
    double? serviceFee,
    double? amountPaid,
    double? balanceAmount,
    PaymentStatus? paymentStatus,
    ContractStatus? contractStatus,
    bool? isReplacementUsed,
    DateTime? replacementDate,
    String? replacementCandidateId,
    String? createdBy,
    String? remarks
  }) {
    return ContractModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      candidateId: candidateId ?? this.candidateId,
      clientName: clientName ?? this.clientName,
      candidateName: candidateName ?? this.candidateName,
      placementDate: placementDate ?? this.placementDate,
      guaranteeEndDate: guaranteeEndDate ?? this.guaranteeEndDate,
      serviceFee: serviceFee ?? this.serviceFee,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      contractStatus: contractStatus ?? this.contractStatus,
      isReplacementUsed: isReplacementUsed ?? this.isReplacementUsed,
      replacementDate: replacementDate ?? this.replacementDate,
      replacementCandidateId: replacementCandidateId ?? this.replacementCandidateId,
      createdBy: createdBy ?? this.createdBy,
      remarks: remarks ?? this.remarks
    );
  }

  @override
  String toString() => 'ContractModel(id: $id, client: $clientName, candidate: $candidateName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
