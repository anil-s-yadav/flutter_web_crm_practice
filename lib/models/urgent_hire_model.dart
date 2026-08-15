import 'package:equatable/equatable.dart';

enum UrgentHireStatus { pending, inProgress, fulfilled, cancelled }

extension UrgentHireStatusExtension on UrgentHireStatus {
  String get displayName {
    switch (this) {
      case UrgentHireStatus.pending:
        return 'Pending';
      case UrgentHireStatus.inProgress:
        return 'In Progress';
      case UrgentHireStatus.fulfilled:
        return 'Fulfilled';
      case UrgentHireStatus.cancelled:
        return 'Cancelled';
    }
  }

  static UrgentHireStatus fromString(String? value) {
    if (value == null) return UrgentHireStatus.pending;
    switch (value.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return UrgentHireStatus.inProgress;
      case 'fulfilled':
      case 'completed':
        return UrgentHireStatus.fulfilled;
      case 'cancelled':
      case 'canceled':
        return UrgentHireStatus.cancelled;
      default:
        return UrgentHireStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case UrgentHireStatus.pending:
        return 'pending';
      case UrgentHireStatus.inProgress:
        return 'in_progress';
      case UrgentHireStatus.fulfilled:
        return 'fulfilled';
      case UrgentHireStatus.cancelled:
        return 'cancelled';
    }
  }
}

class UrgentHireModel extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String clientCity;
  final String? requestedById;
  final String requestedByName;
  final String category;
  final String serviceType;
  final String workTimings;
  final String budgetRange;
  final String foodPreference;
  final String genderPreference;
  final String preferredLanguages;
  final String religionPreference;
  final String expectedJoining;
  final String notes;
  final UrgentHireStatus status;
  final String? fulfilledCandidateId;
  final String? fulfilledCandidateName;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UrgentHireModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientPhone = '',
    this.clientCity = '',
    this.requestedById,
    this.requestedByName = '',
    required this.category,
    this.serviceType = '24 Hours Live-in',
    this.workTimings = '24 Hours',
    this.budgetRange = '',
    this.foodPreference = 'Any / No Preference',
    this.genderPreference = 'Female',
    this.preferredLanguages = 'Hindi',
    this.religionPreference = 'Any / No Preference',
    this.expectedJoining = 'Immediate (Within 1-2 Days)',
    this.notes = '',
    this.status = UrgentHireStatus.pending,
    this.fulfilledCandidateId,
    this.fulfilledCandidateName,
    this.priority = 'urgent',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UrgentHireModel.fromJson(Map<String, dynamic> json) {
    return UrgentHireModel(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? json['clientId'] ?? '',
      clientName: json['client_name'] ?? json['clientName'] ?? '',
      clientPhone: json['client_phone'] ?? json['clientPhone'] ?? json['live_client_phone'] ?? '',
      clientCity: json['client_city'] ?? json['clientCity'] ?? json['live_client_city'] ?? '',
      requestedById: json['requested_by_id'] ?? json['requestedById'],
      requestedByName: json['requested_by_name'] ?? json['requestedByName'] ?? '',
      category: json['category'] ?? '',
      serviceType: json['service_type'] ?? json['serviceType'] ?? '24 Hours Live-in',
      workTimings: json['work_timings'] ?? json['workTimings'] ?? '24 Hours',
      budgetRange: json['budget_range'] ?? json['budgetRange'] ?? '',
      foodPreference: json['food_preference'] ?? json['foodPreference'] ?? 'Any / No Preference',
      genderPreference: json['gender_preference'] ?? json['genderPreference'] ?? 'Female',
      preferredLanguages: json['preferred_languages'] ?? json['preferredLanguages'] ?? 'Hindi',
      religionPreference: json['religion_preference'] ?? json['religionPreference'] ?? 'Any / No Preference',
      expectedJoining: json['expected_joining'] ?? json['expectedJoining'] ?? 'Immediate (Within 1-2 Days)',
      notes: json['notes'] ?? '',
      status: UrgentHireStatusExtension.fromString(json['status']?.toString()),
      fulfilledCandidateId: json['fulfilled_candidate_id'] ?? json['fulfilledCandidateId'],
      fulfilledCandidateName: json['fulfilled_candidate_name'] ?? json['fulfilledCandidateName'],
      priority: json['priority'] ?? 'urgent',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_city': clientCity,
      'requested_by_id': requestedById,
      'requested_by_name': requestedByName,
      'category': category,
      'service_type': serviceType,
      'work_timings': workTimings,
      'budget_range': budgetRange,
      'food_preference': foodPreference,
      'gender_preference': genderPreference,
      'preferred_languages': preferredLanguages,
      'religion_preference': religionPreference,
      'expected_joining': expectedJoining,
      'notes': notes,
      'status': status.toDbString(),
      'fulfilled_candidate_id': fulfilledCandidateId,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UrgentHireModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? clientCity,
    String? requestedById,
    String? requestedByName,
    String? category,
    String? serviceType,
    String? workTimings,
    String? budgetRange,
    String? foodPreference,
    String? genderPreference,
    String? preferredLanguages,
    String? religionPreference,
    String? expectedJoining,
    String? notes,
    UrgentHireStatus? status,
    String? fulfilledCandidateId,
    String? fulfilledCandidateName,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UrgentHireModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientCity: clientCity ?? this.clientCity,
      requestedById: requestedById ?? this.requestedById,
      requestedByName: requestedByName ?? this.requestedByName,
      category: category ?? this.category,
      serviceType: serviceType ?? this.serviceType,
      workTimings: workTimings ?? this.workTimings,
      budgetRange: budgetRange ?? this.budgetRange,
      foodPreference: foodPreference ?? this.foodPreference,
      genderPreference: genderPreference ?? this.genderPreference,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      religionPreference: religionPreference ?? this.religionPreference,
      expectedJoining: expectedJoining ?? this.expectedJoining,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      fulfilledCandidateId: fulfilledCandidateId ?? this.fulfilledCandidateId,
      fulfilledCandidateName: fulfilledCandidateName ?? this.fulfilledCandidateName,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        clientPhone,
        clientCity,
        requestedById,
        requestedByName,
        category,
        serviceType,
        workTimings,
        budgetRange,
        foodPreference,
        genderPreference,
        preferredLanguages,
        religionPreference,
        expectedJoining,
        notes,
        status,
        fulfilledCandidateId,
        fulfilledCandidateName,
        priority,
        createdAt,
        updatedAt,
      ];
}
