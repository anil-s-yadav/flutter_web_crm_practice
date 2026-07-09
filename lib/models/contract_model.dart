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
  final String maidId;
  final String clientName;
  final String maidName;
  final DateTime placementDate;
  final DateTime guaranteeEndDate;
  final double serviceFee;
  final double amountPaid;
  final double balanceAmount;
  final PaymentStatus paymentStatus;
  final ContractStatus contractStatus;
  final bool isReplacementUsed;
  final DateTime? replacementDate;
  final String? replacementMaidId;
  final String createdBy;
  final String? remarks;

  const ContractModel({
    required this.id,
    required this.clientId,
    required this.maidId,
    required this.clientName,
    required this.maidName,
    required this.placementDate,
    required this.guaranteeEndDate,
    required this.serviceFee,
    required this.amountPaid,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.contractStatus,
    this.isReplacementUsed = false,
    this.replacementDate,
    this.replacementMaidId,
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
      maidId: json['maidId'] as String,
      clientName: json['clientName'] as String,
      maidName: json['maidName'] as String,
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
      replacementMaidId: json['replacementMaidId'] as String?,
      createdBy: json['createdBy'] as String,
      remarks: json['remarks'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'maidId': maidId,
      'clientName': clientName,
      'maidName': maidName,
      'placementDate': placementDate.toIso8601String(),
      'guaranteeEndDate': guaranteeEndDate.toIso8601String(),
      'serviceFee': serviceFee,
      'amountPaid': amountPaid,
      'balanceAmount': balanceAmount,
      'paymentStatus': paymentStatus.name,
      'contractStatus': contractStatus.name,
      'isReplacementUsed': isReplacementUsed,
      'replacementDate': replacementDate?.toIso8601String(),
      'replacementMaidId': replacementMaidId,
      'createdBy': createdBy,
      'remarks': remarks
    };
  }

  String toJsonString() => jsonEncode(toJson());

  ContractModel copyWith({
    String? id,
    String? clientId,
    String? maidId,
    String? clientName,
    String? maidName,
    DateTime? placementDate,
    DateTime? guaranteeEndDate,
    double? serviceFee,
    double? amountPaid,
    double? balanceAmount,
    PaymentStatus? paymentStatus,
    ContractStatus? contractStatus,
    bool? isReplacementUsed,
    DateTime? replacementDate,
    String? replacementMaidId,
    String? createdBy,
    String? remarks
  }) {
    return ContractModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      maidId: maidId ?? this.maidId,
      clientName: clientName ?? this.clientName,
      maidName: maidName ?? this.maidName,
      placementDate: placementDate ?? this.placementDate,
      guaranteeEndDate: guaranteeEndDate ?? this.guaranteeEndDate,
      serviceFee: serviceFee ?? this.serviceFee,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      contractStatus: contractStatus ?? this.contractStatus,
      isReplacementUsed: isReplacementUsed ?? this.isReplacementUsed,
      replacementDate: replacementDate ?? this.replacementDate,
      replacementMaidId: replacementMaidId ?? this.replacementMaidId,
      createdBy: createdBy ?? this.createdBy,
      remarks: remarks ?? this.remarks
    );
  }

  @override
  String toString() => 'ContractModel(id: $id, client: $clientName, maid: $maidName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
