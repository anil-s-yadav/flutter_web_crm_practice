import 'dart:convert';

enum PaymentStatus { pending, partial, paid, overdue }

enum ContractStatus { pending, active, completed, rePlaced, cancelled }

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
      orElse: () => PaymentStatus.pending,
    );
  }
}

extension ContractStatusExtension on ContractStatus {
  String get displayName {
    switch (this) {
      case ContractStatus.pending:
        return 'Pending';
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.completed:
        return 'Completed';
      case ContractStatus.rePlaced:
        return 'RePlaced';
      case ContractStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContractStatus.pending,
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
  final DateTime contractEndDate;
  final DateTime guaranteeEndDate;
  final double serviceFee;
  final double amountPaid;
  final double balanceAmount;
  final PaymentStatus paymentStatus;
  final ContractStatus contractStatus;
  final bool isReplacementUsed;
  final DateTime? replacementDate;
  final String? replacementCandidateId;
  final DateTime? renewedOn;
  final bool isRenewal;
  final int replacementsUsed;
  final String createdBy;
  final String? remarks;

  const ContractModel({
    required this.id,
    required this.clientId,
    required this.candidateId,
    required this.clientName,
    required this.candidateName,
    required this.placementDate,
    required this.contractEndDate,
    required this.guaranteeEndDate,
    required this.serviceFee,
    required this.amountPaid,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.contractStatus,
    this.isReplacementUsed = false,
    this.replacementDate,
    this.replacementCandidateId,
    this.renewedOn,
    this.isRenewal = false,
    this.replacementsUsed = 0,
    required this.createdBy,
    this.remarks,
  });

  int get daysRemainingInGuarantee {
    final now = DateTime.now();
    if (now.isAfter(guaranteeEndDate)) return 0;
    return guaranteeEndDate.difference(now).inDays;
  }

  int get daysRemainingInContract {
    final now = DateTime.now();
    if (now.isAfter(contractEndDate)) return 0;
    return contractEndDate.difference(now).inDays;
  }

  bool get isGuaranteeActive {
    return DateTime.now().isBefore(guaranteeEndDate);
  }

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return ContractModel(
      id: (json['id'] ?? '').toString(),
      clientId: (json['clientId'] ?? json['client_id'] ?? '').toString(),
      candidateId: (json['candidateId'] ?? json['candidate_id'] ?? '').toString(),
      clientName: (json['clientName'] ?? json['client_name'] ?? 'Unknown Client').toString(),
      candidateName: (json['candidateName'] ?? json['candidate_name'] ?? 'Unknown Candidate').toString(),
      placementDate: DateTime.parse((json['placementDate'] ?? json['start_date'] ?? DateTime.now().toIso8601String()).toString()),
      contractEndDate: DateTime.parse((json['contractEndDate'] ?? json['contract_end_date'] ?? DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day).toIso8601String()).toString()),
      guaranteeEndDate: DateTime.parse((json['guaranteeEndDate'] ?? json['guarantee_end_date'] ?? DateTime.now().toIso8601String()).toString()),
      serviceFee: parseDouble(json['serviceFee'] ?? json['total_fee']),
      amountPaid: parseDouble(json['amountPaid'] ?? json['amount_paid']),
      balanceAmount: parseDouble(json['balanceAmount'] ?? json['balance_amount']),
      paymentStatus: PaymentStatusExtension.fromString(
        (json['paymentStatus'] ?? json['payment_status'] ?? 'pending').toString(),
      ),
      contractStatus: ContractStatusExtension.fromString(
        (json['contractStatus'] ?? json['status'] ?? 'pending').toString(),
      ),
      isReplacementUsed: (json['isReplacementUsed'] ?? json['is_replacement_used'] ?? false) == true || json['is_replacement_used'] == 1,
      replacementDate:
          (json['replacementDate'] ?? json['replacement_date']) != null
              ? DateTime.parse((json['replacementDate'] ?? json['replacement_date']).toString())
              : null,
      replacementCandidateId: (json['replacementCandidateId'] ?? json['replacement_candidate_id'])?.toString(),
      renewedOn:
          (json['renewedOn'] ?? json['renewed_on']) != null
              ? DateTime.parse((json['renewedOn'] ?? json['renewed_on']).toString())
              : null,
      isRenewal: (json['isRenewal'] ?? json['is_renewal'] ?? false) == true || json['is_renewal'] == 1,
      replacementsUsed: ((json['replacementsUsed'] ?? json['replacements_used'] ?? 0) as num).toInt(),
      createdBy: (json['createdBy'] ?? json['created_by'] ?? 'System').toString(),
      remarks: (json['remarks'] ?? json['notes'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'client_id': clientId,
      'candidateId': candidateId,
      'candidate_id': candidateId,
      'clientName': clientName,
      'candidateName': candidateName,
      'placementDate': placementDate.toIso8601String(),
      'start_date': placementDate.toIso8601String(),
      'guaranteeEndDate': guaranteeEndDate.toIso8601String(),
      'guarantee_end_date': guaranteeEndDate.toIso8601String(),
      'contractEndDate': contractEndDate.toIso8601String(),
      'contract_end_date': contractEndDate.toIso8601String(),
      'serviceFee': serviceFee,
      'total_fee': serviceFee,
      'amountPaid': amountPaid,
      'balanceAmount': balanceAmount,
      'paymentStatus': paymentStatus.name,
      'contractStatus': contractStatus.name,
      'isReplacementUsed': isReplacementUsed,
      'replacementDate': replacementDate?.toIso8601String(),
      'replacementCandidateId': replacementCandidateId,
      'renewedOn': renewedOn?.toIso8601String(),
      'isRenewal': isRenewal,
      'replacementsUsed': replacementsUsed,
      'createdBy': createdBy,
      'remarks': remarks,
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
    DateTime? contractEndDate,
    DateTime? guaranteeEndDate,
    double? serviceFee,
    double? amountPaid,
    double? balanceAmount,
    PaymentStatus? paymentStatus,
    ContractStatus? contractStatus,
    bool? isReplacementUsed,
    DateTime? replacementDate,
    String? replacementCandidateId,
    DateTime? renewedOn,
    bool? isRenewal,
    int? replacementsUsed,
    String? createdBy,
    String? remarks,
  }) {
    return ContractModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      candidateId: candidateId ?? this.candidateId,
      clientName: clientName ?? this.clientName,
      candidateName: candidateName ?? this.candidateName,
      placementDate: placementDate ?? this.placementDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      guaranteeEndDate: guaranteeEndDate ?? this.guaranteeEndDate,
      serviceFee: serviceFee ?? this.serviceFee,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      contractStatus: contractStatus ?? this.contractStatus,
      isReplacementUsed: isReplacementUsed ?? this.isReplacementUsed,
      replacementDate: replacementDate ?? this.replacementDate,
      replacementCandidateId:
          replacementCandidateId ?? this.replacementCandidateId,
      renewedOn: renewedOn ?? this.renewedOn,
      isRenewal: isRenewal ?? this.isRenewal,
      replacementsUsed: replacementsUsed ?? this.replacementsUsed,
      createdBy: createdBy ?? this.createdBy,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  String toString() =>
      'ContractModel(id: $id, client: $clientName, candidate: $candidateName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
