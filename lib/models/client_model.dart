import 'dart:convert';

enum ClientStatus {
  followUp,
  interested,
  notInterested,
  converted,
  inactive,
}

extension ClientStatusExtension on ClientStatus {
  String get displayName {
    switch (this) {
      case ClientStatus.followUp:
        return 'Follow Up';
      case ClientStatus.interested:
        return 'Interested';
      case ClientStatus.notInterested:
        return 'Not Interested';
      case ClientStatus.converted:
        return 'Converted (Active)';
      case ClientStatus.inactive:
        return 'Inactive / Past';
    }
  }

  static ClientStatus fromString(String value) {
    if (value == 'newInquiry' || value == 'lead' || value == 'follow_up') {
      return ClientStatus.followUp;
    }
    if (value == 'noResponse' || value == 'not_interested') {
      return ClientStatus.notInterested;
    }
    if (value == 'active' || value == 'churned') {
      return ClientStatus.converted;
    }

    return ClientStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClientStatus.followUp,
    );
  }
}

class ClientModel {
  final String id;
  final String fullName;
  final String phone;
  final String? altPhone;
  final String email;
  final String address;
  final String city;
  final String locality;
  final String houseType;
  final int familySize;
  final bool hasPets;
  final String? petDetails;
  final bool hasElderlyMembers;
  final bool hasChildren;
  final int? childrenCount;
  final String preferredCandidateCategory;
  final List<String> requiredSkills;
  final String budgetRange;
  final ClientStatus status;
  final String? assignedEmployeeId;
  final String? assignedEmployeeName;
  final String source;
  final DateTime inquiryDate;
  final int renewalCount;
  final String? remarks;

  // Service Requirements
  final String serviceType;
  final String workTimings;
  final String foodPreference;
  final String genderPreference;
  final List<String> preferredLanguages;
  final String religionPreference;
  final String expectedJoining;
  final String contractDuration;

  const ClientModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.altPhone,
    required this.email,
    required this.address,
    required this.city,
    required this.locality,
    required this.houseType,
    required this.familySize,
    this.hasPets = false,
    this.petDetails,
    this.hasElderlyMembers = false,
    this.hasChildren = false,
    this.childrenCount,
    required this.preferredCandidateCategory,
    required this.requiredSkills,
    required this.budgetRange,
    required this.status,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    required this.source,
    required this.inquiryDate,
    this.renewalCount = 0,
    this.remarks,
    this.serviceType = '24 Hours Live-in',
    this.workTimings = '24 Hours',
    this.foodPreference = 'Any / No Preference',
    this.genderPreference = 'Female',
    this.preferredLanguages = const ['Hindi'],
    this.religionPreference = 'Any / No Preference',
    this.expectedJoining = 'Immediate (Within 1-2 Days)',
    this.contractDuration = '1 Year',
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    List<String> parseSkills(dynamic raw) {
      if (raw == null) return const ['Standard Duty'];
      if (raw is List) return List<String>.from(raw);
      if (raw is String) {
        if (raw.trim().isEmpty) return const ['Standard Duty'];
        return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return const ['Standard Duty'];
    }

    List<String> parseLanguages(dynamic raw) {
      if (raw == null) return const ['Hindi'];
      if (raw is List) return List<String>.from(raw);
      if (raw is String) {
        if (raw.trim().isEmpty) return const ['Hindi'];
        return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return const ['Hindi'];
    }

    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is DateTime) return raw;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    int parseInt(dynamic val, int fallback) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    return ClientModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      altPhone: (json['alternate_phone'] ?? json['altPhone'])?.toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      city: (json['city'] ?? 'Mumbai').toString(),
      locality: (json['locality'] ?? 'Andheri').toString(),
      houseType: (json['houseType'] ?? json['house_type'] ?? 'Apartment').toString(),
      familySize: parseInt(json['familySize'] ?? json['family_size'], 4),
      hasPets: parseBool(json['hasPets'] ?? json['has_pets']),
      petDetails: (json['petDetails'] ?? json['pet_details'])?.toString(),
      hasElderlyMembers: parseBool(json['hasElderlyMembers'] ?? json['has_elderly_members']),
      hasChildren: parseBool(json['hasChildren'] ?? json['has_children']),
      childrenCount: json['childrenCount'] != null 
          ? parseInt(json['childrenCount'], 0) 
          : (json['children_count'] != null ? parseInt(json['children_count'], 0) : null),
      preferredCandidateCategory: (json['preferredCandidateCategory'] ?? json['preferred_category'] ?? 'House Maid').toString(),
      requiredSkills: parseSkills(json['requiredSkills'] ?? json['required_skills']),
      budgetRange: (json['budgetRange'] ?? json['budget_range'] ?? '₹15,000 - ₹25,000').toString(),
      status: ClientStatusExtension.fromString((json['status'] ?? 'followUp').toString()),
      assignedEmployeeId: (json['assignedEmployeeId'] ?? json['assigned_sales_id'])?.toString(),
      assignedEmployeeName: (json['assignedEmployeeName'] ?? json['assigned_sales_name'])?.toString(),
      source: (json['source'] ?? 'Direct / Walk-in').toString(),
      inquiryDate: parseDate(json['inquiryDate'] ?? json['inquiry_date'] ?? json['created_at']),
      renewalCount: parseInt(json['renewalCount'] ?? json['renewal_count'], 0),
      remarks: (json['remarks'] ?? json['notes'])?.toString(),
      serviceType: (json['serviceType'] ?? json['service_type'] ?? '24 Hours Live-in').toString(),
      workTimings: (json['workTimings'] ?? json['work_timings'] ?? '24 Hours').toString(),
      foodPreference: (json['foodPreference'] ?? json['food_preference'] ?? 'Any / No Preference').toString(),
      genderPreference: (json['genderPreference'] ?? json['gender_preference'] ?? 'Female').toString(),
      preferredLanguages: parseLanguages(json['preferredLanguages'] ?? json['preferred_languages']),
      religionPreference: (json['religionPreference'] ?? json['religion_preference'] ?? 'Any / No Preference').toString(),
      expectedJoining: (json['expectedJoining'] ?? json['expected_joining'] ?? 'Immediate (Within 1-2 Days)').toString(),
      contractDuration: (json['contractDuration'] ?? json['contract_duration'] ?? '1 Year').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'name': fullName,
      'phone': phone,
      'alternate_phone': altPhone,
      'altPhone': altPhone,
      'email': email,
      'address': address,
      'city': city,
      'locality': locality,
      'houseType': houseType,
      'house_type': houseType,
      'familySize': familySize,
      'family_size': familySize,
      'hasPets': hasPets,
      'has_pets': hasPets,
      'petDetails': petDetails,
      'pet_details': petDetails,
      'hasElderlyMembers': hasElderlyMembers,
      'has_elderly_members': hasElderlyMembers,
      'hasChildren': hasChildren,
      'has_children': hasChildren,
      'childrenCount': childrenCount,
      'children_count': childrenCount,
      'preferredCandidateCategory': preferredCandidateCategory,
      'preferred_category': preferredCandidateCategory,
      'requiredSkills': requiredSkills,
      'required_skills': requiredSkills.join(', '),
      'budgetRange': budgetRange,
      'budget_range': budgetRange,
      'status': status.name,
      'assignedEmployeeId': assignedEmployeeId,
      'assigned_sales_id': assignedEmployeeId,
      'assigned_sales_name': assignedEmployeeName,
      'source': source,
      'inquiryDate': inquiryDate.toIso8601String(),
      'renewalCount': renewalCount,
      'renewal_count': renewalCount,
      'remarks': remarks,
      'serviceType': serviceType,
      'service_type': serviceType,
      'workTimings': workTimings,
      'work_timings': workTimings,
      'foodPreference': foodPreference,
      'food_preference': foodPreference,
      'genderPreference': genderPreference,
      'gender_preference': genderPreference,
      'preferredLanguages': preferredLanguages,
      'preferred_languages': preferredLanguages.join(', '),
      'religionPreference': religionPreference,
      'religion_preference': religionPreference,
      'expectedJoining': expectedJoining,
      'expected_joining': expectedJoining,
      'contractDuration': contractDuration,
      'contract_duration': contractDuration,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  ClientModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? altPhone,
    String? email,
    String? address,
    String? city,
    String? locality,
    String? houseType,
    int? familySize,
    bool? hasPets,
    String? petDetails,
    bool? hasElderlyMembers,
    bool? hasChildren,
    int? childrenCount,
    String? preferredCandidateCategory,
    List<String>? requiredSkills,
    String? budgetRange,
    ClientStatus? status,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    String? source,
    DateTime? inquiryDate,
    int? renewalCount,
    String? remarks,
    String? serviceType,
    String? workTimings,
    String? foodPreference,
    String? genderPreference,
    List<String>? preferredLanguages,
    String? religionPreference,
    String? expectedJoining,
    String? contractDuration,
  }) {
    return ClientModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      houseType: houseType ?? this.houseType,
      familySize: familySize ?? this.familySize,
      hasPets: hasPets ?? this.hasPets,
      petDetails: petDetails ?? this.petDetails,
      hasElderlyMembers: hasElderlyMembers ?? this.hasElderlyMembers,
      hasChildren: hasChildren ?? this.hasChildren,
      childrenCount: childrenCount ?? this.childrenCount,
      preferredCandidateCategory: preferredCandidateCategory ?? this.preferredCandidateCategory,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      budgetRange: budgetRange ?? this.budgetRange,
      status: status ?? this.status,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      source: source ?? this.source,
      inquiryDate: inquiryDate ?? this.inquiryDate,
      renewalCount: renewalCount ?? this.renewalCount,
      remarks: remarks ?? this.remarks,
      serviceType: serviceType ?? this.serviceType,
      workTimings: workTimings ?? this.workTimings,
      foodPreference: foodPreference ?? this.foodPreference,
      genderPreference: genderPreference ?? this.genderPreference,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      religionPreference: religionPreference ?? this.religionPreference,
      expectedJoining: expectedJoining ?? this.expectedJoining,
      contractDuration: contractDuration ?? this.contractDuration,
    );
  }

  @override
  String toString() => 'ClientModel(id: $id, name: $fullName, status: ${status.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
