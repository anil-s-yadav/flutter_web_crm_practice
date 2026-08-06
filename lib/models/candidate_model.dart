import 'dart:convert';

enum CandidateStatus {
  newlyAdded,
  verificationPending,
  medicalPending,
  readyToPlace,
  Placed,
  renewalPending,
  jobLeft,
  blacklisted,
}

extension CandidateStatusExtension on CandidateStatus {
  String get displayName {
    switch (this) {
      case CandidateStatus.newlyAdded:
        return 'Newly Added';
      case CandidateStatus.verificationPending:
        return 'Verification Pending';
      case CandidateStatus.medicalPending:
        return 'Medical Pending';
      case CandidateStatus.readyToPlace:
        return 'Ready to Place';
      case CandidateStatus.Placed:
        return 'Placed';
      case CandidateStatus.renewalPending:
        return 'Renewal Pending';
      case CandidateStatus.jobLeft:
        return 'Job Left';
      case CandidateStatus.blacklisted:
        return 'Blacklisted';
    }
  }

  static CandidateStatus fromString(String value) {
    return CandidateStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CandidateStatus.newlyAdded,
    );
  }
}

class CandidateModel {
  final String id;
  final String fullName;
  final int age;
  final String phone;
  final String? altPhone;
  final String photoUrl;
  final String address;
  final String city;
  final String state;
  final List<String> languages;
  final String religion;
  final String category;
  final String education;
  final int experienceYears;
  final String expectedSalary;
  final int workingHoursPerDay;
  final String? preferredWorkType;
  final CandidateStatus status;

  // Verification Flags
  final bool isMedicalCleared;
  final bool isPoliceVerified;

  // Document URLs
  final String? medicalClearanceDocUrl;
  final String? policeVerificationDocUrl;
  final String? aadhaarDocUrl;
  final String? panDocUrl;
  final String? passportDocUrl;

  // Placement & Metadata
  final String? currentPlacementId; // nullable - linked to a Contract
  final String addedBy;
  final DateTime dateAdded;
  final DateTime? dateVerificationSent;
  final DateTime? dateMedicalSent;
  final DateTime? dateReadyToHire;
  final DateTime? datePlaced;
  final DateTime? availableFrom;
  final String? remarks;

  // Sourcing User Details & Source
  final String? sourcedById;
  final String? sourcedByName;
  final String? sourcedByPhone;
  final String source;

  CandidateModel({
    required this.id,
    required this.fullName,
    required this.age,
    required this.phone,
    this.altPhone,
    required this.address,
    required this.city,
    required this.state,
    required this.languages,
    required this.religion,
    required this.category,
    required this.education,
    required this.experienceYears,
    required this.expectedSalary,
    required this.workingHoursPerDay,
    this.preferredWorkType,
    required this.status,
    required this.isMedicalCleared,
    required this.isPoliceVerified,
    this.medicalClearanceDocUrl,
    this.policeVerificationDocUrl,
    this.aadhaarDocUrl,
    this.panDocUrl,
    this.passportDocUrl,
    this.photoUrl = '',
    this.currentPlacementId,
    required this.addedBy,
    required this.dateAdded,
    this.dateVerificationSent,
    this.dateMedicalSent,
    this.dateReadyToHire,
    this.datePlaced,
    this.availableFrom,
    this.remarks,
    this.sourcedById,
    this.sourcedByName,
    this.sourcedByPhone,
    this.source = 'Direct / Walk-in',
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    // Support both camelCase (mock JSON) and snake_case (MySQL DB) keys
    final languagesRaw = json['languages'];
    List<String> languages;
    if (languagesRaw is List) {
      languages = List<String>.from(languagesRaw);
    } else if (languagesRaw is String && languagesRaw.isNotEmpty) {
      languages = languagesRaw.split(',').map((e) => e.trim()).toList();
    } else {
      languages = ['Hindi'];
    }

    final dateAddedRaw = json['dateAdded'] ?? json['created_at'];
    DateTime dateAdded;
    if (dateAddedRaw is String) {
      dateAdded = DateTime.tryParse(dateAddedRaw) ?? DateTime.now();
    } else {
      dateAdded = DateTime.now();
    }

    bool parseBoolField(dynamic val1, dynamic val2) {
      if (val1 == true || val1 == 1 || val1 == '1' || val1 == 'true') return true;
      if (val1 == false || val1 == 0 || val1 == '0' || val1 == 'false') return false;
      if (val2 == true || val2 == 1 || val2 == '1' || val2 == 'true') return true;
      return false;
    }

    return CandidateModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      age: json['age'] ?? 25,
      phone: json['phone'] ?? '',
      altPhone: json['altPhone'] ?? json['alternate_phone'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      languages: languages,
      religion: json['religion'] ?? '',
      category: json['category'] ?? '',
      education: json['education'] ?? 'Not Specified',
      experienceYears: json['experienceYears'] ?? json['experience_years'] ?? 0,
      expectedSalary: (json['expectedSalary'] ?? json['expected_salary'] ?? '').toString(),
      workingHoursPerDay: json['workingHoursPerDay'] ?? json['working_hours_per_day'] ?? 10,
      preferredWorkType: json['preferredWorkType'] ?? json['preferred_work_type'],
      status: CandidateStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'newlyAdded'),
        orElse: () => CandidateStatus.newlyAdded,
      ),
      isMedicalCleared: parseBoolField(json['isMedicalCleared'], json['is_medical_cleared']),
      isPoliceVerified: parseBoolField(json['isPoliceVerified'], json['is_police_verified']),
      medicalClearanceDocUrl: json['medicalClearanceDocUrl'] ?? json['medical_clearance_doc_url'],
      policeVerificationDocUrl: json['policeVerificationDocUrl'] ?? json['police_verification_doc_url'],
      aadhaarDocUrl: json['aadhaarDocUrl'] ?? json['aadhaar_doc_url'],
      panDocUrl: json['panDocUrl'] ?? json['pan_doc_url'],
      passportDocUrl: json['passportDocUrl'] ?? json['passport_doc_url'],
      photoUrl: json['photoUrl'] ?? json['profile_image_url'] ?? '',
      currentPlacementId: json['currentPlacementId'] ?? json['current_placement_id'],
      addedBy: json['addedBy'] ?? json['sourced_by_id'] ?? 'System',
      dateAdded: dateAdded,
      dateVerificationSent: _tryParseDate(json['dateVerificationSent'] ?? json['date_verification_sent']),
      dateMedicalSent: _tryParseDate(json['dateMedicalSent'] ?? json['date_medical_sent']),
      dateReadyToHire: _tryParseDate(json['dateReadyToHire'] ?? json['date_ready_to_hire']),
      datePlaced: _tryParseDate(json['datePlaced'] ?? json['date_placed']),
      availableFrom: _tryParseDate(json['availableFrom'] ?? json['available_from']),
      remarks: json['remarks'],
      sourcedById: json['sourcedById'] ?? json['sourced_by_id'],
      sourcedByName: json['sourcedByName'] ?? json['sourced_by_name'],
      sourcedByPhone: json['sourcedByPhone'] ?? json['sourced_by_phone'],
      source: (json['source'] ?? 'Direct / Walk-in').toString(),
    );
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'full_name': fullName,
      'age': age,
      'phone': phone,
      'alternate_phone': altPhone,
      'altPhone': altPhone,
      'address': address,
      'city': city,
      'state': state,
      'languages': languages,
      'religion': religion,
      'category': category,
      'education': education,
      'experienceYears': experienceYears,
      'experience_years': experienceYears,
      'expectedSalary': expectedSalary,
      'expected_salary': expectedSalary,
      'workingHoursPerDay': workingHoursPerDay,
      'working_hours_per_day': workingHoursPerDay,
      'preferredWorkType': preferredWorkType,
      'preferred_work_type': preferredWorkType,
      'status': status.toString().split('.').last,
      'isMedicalCleared': isMedicalCleared,
      'is_medical_cleared': isMedicalCleared,
      'isPoliceVerified': isPoliceVerified,
      'is_police_verified': isPoliceVerified,
      'medicalClearanceDocUrl': medicalClearanceDocUrl,
      'medical_clearance_doc_url': medicalClearanceDocUrl,
      'policeVerificationDocUrl': policeVerificationDocUrl,
      'police_verification_doc_url': policeVerificationDocUrl,
      'aadhaarDocUrl': aadhaarDocUrl,
      'aadhaar_doc_url': aadhaarDocUrl,
      'panDocUrl': panDocUrl,
      'pan_doc_url': panDocUrl,
      'passportDocUrl': passportDocUrl,
      'passport_doc_url': passportDocUrl,
      'photoUrl': photoUrl,
      'profile_image_url': photoUrl,
      'currentPlacementId': currentPlacementId,
      'addedBy': addedBy,
      'dateAdded': dateAdded.toIso8601String(),
      'dateVerificationSent': dateVerificationSent?.toIso8601String(),
      'dateMedicalSent': dateMedicalSent?.toIso8601String(),
      'dateReadyToHire': dateReadyToHire?.toIso8601String(),
      'datePlaced': datePlaced?.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
      'remarks': remarks,
      'sourcedById': sourcedById,
      'sourced_by_id': sourcedById,
      'sourcedByName': sourcedByName,
      'sourced_by_name': sourcedByName,
      'sourcedByPhone': sourcedByPhone,
      'sourced_by_phone': sourcedByPhone,
      'source': source,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  String get formattedExpectedSalary {
    if (expectedSalary.trim().isEmpty) return '₹15,000 - ₹25,000';
    final trimmed = expectedSalary.trim();
    if (trimmed.contains('₹')) return trimmed;
    return '₹$trimmed';
  }

  CandidateModel copyWith({
    String? id,
    String? fullName,
    int? age,
    String? phone,
    String? altPhone,
    String? address,
    String? city,
    String? state,
    List<String>? languages,
    String? religion,
    String? category,
    String? education,
    int? experienceYears,
    String? expectedSalary,
    int? workingHoursPerDay,
    String? preferredWorkType,
    CandidateStatus? status,
    bool? isMedicalCleared,
    bool? isPoliceVerified,
    String? medicalClearanceDocUrl,
    String? policeVerificationDocUrl,
    String? aadhaarDocUrl,
    String? panDocUrl,
    String? passportDocUrl,
    String? photoUrl,
    String? currentPlacementId,
    DateTime? dateVerificationSent,
    DateTime? dateMedicalSent,
    DateTime? dateReadyToHire,
    DateTime? datePlaced,
    DateTime? availableFrom,
    String? remarks,
    String? sourcedById,
    String? sourcedByName,
    String? sourcedByPhone,
    String? source,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      languages: languages ?? this.languages,
      religion: religion ?? this.religion,
      category: category ?? this.category,
      education: education ?? this.education,
      experienceYears: experienceYears ?? this.experienceYears,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      workingHoursPerDay: workingHoursPerDay ?? this.workingHoursPerDay,
      preferredWorkType: preferredWorkType ?? this.preferredWorkType,
      status: status ?? this.status,
      isMedicalCleared: isMedicalCleared ?? this.isMedicalCleared,
      isPoliceVerified: isPoliceVerified ?? this.isPoliceVerified,
      medicalClearanceDocUrl:
          medicalClearanceDocUrl ?? this.medicalClearanceDocUrl,
      policeVerificationDocUrl:
          policeVerificationDocUrl ?? this.policeVerificationDocUrl,
      aadhaarDocUrl: aadhaarDocUrl ?? this.aadhaarDocUrl,
      panDocUrl: panDocUrl ?? this.panDocUrl,
      passportDocUrl: passportDocUrl ?? this.passportDocUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      currentPlacementId: currentPlacementId ?? this.currentPlacementId,
      addedBy: addedBy,
      dateAdded: dateAdded,
      dateVerificationSent: dateVerificationSent ?? this.dateVerificationSent,
      dateMedicalSent: dateMedicalSent ?? this.dateMedicalSent,
      dateReadyToHire: dateReadyToHire ?? this.dateReadyToHire,
      datePlaced: datePlaced ?? this.datePlaced,
      availableFrom: availableFrom ?? this.availableFrom,
      remarks: remarks ?? this.remarks,
      sourcedById: sourcedById ?? this.sourcedById,
      sourcedByName: sourcedByName ?? this.sourcedByName,
      sourcedByPhone: sourcedByPhone ?? this.sourcedByPhone,
      source: source ?? this.source,
    );
  }

  CandidateModel clearPlacement() {
    return CandidateModel(
      id: id,
      fullName: fullName,
      age: age,
      phone: phone,
      altPhone: altPhone,
      address: address,
      city: city,
      state: state,
      languages: languages,
      religion: religion,
      category: category,
      education: education,
      experienceYears: experienceYears,
      expectedSalary: expectedSalary,
      workingHoursPerDay: workingHoursPerDay,
      preferredWorkType: preferredWorkType,
      status: status,
      isMedicalCleared: isMedicalCleared,
      isPoliceVerified: isPoliceVerified,
      medicalClearanceDocUrl: medicalClearanceDocUrl,
      policeVerificationDocUrl: policeVerificationDocUrl,
      aadhaarDocUrl: aadhaarDocUrl,
      photoUrl: photoUrl,
      currentPlacementId: null, // CLEAR PLACEMENT
      addedBy: addedBy,
      dateAdded: dateAdded,
      dateVerificationSent: dateVerificationSent,
      dateMedicalSent: dateMedicalSent,
      dateReadyToHire: dateReadyToHire,
      datePlaced: datePlaced,
      availableFrom: availableFrom,
      remarks: remarks,
      sourcedById: sourcedById,
      sourcedByName: sourcedByName,
      sourcedByPhone: sourcedByPhone,
      source: source,
    );
  }

  @override
  String toString() =>
      'CandidateModel(id: $id, name: $fullName, status: ${status.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
