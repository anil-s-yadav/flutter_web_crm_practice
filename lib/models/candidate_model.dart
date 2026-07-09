import 'dart:convert';

enum CandidateStatus {
  newlyAdded,
  verificationPending,
  medicalPending,
  readyToPlace,
  placed,
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
      case CandidateStatus.placed:
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
  final bool isAadhaarVerified;

  // Document URLs
  final String? medicalClearanceDocUrl;
  final String? policeVerificationDocUrl;
  final String? aadhaarDocUrl;

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
    required this.isAadhaarVerified,
    this.medicalClearanceDocUrl,
    this.policeVerificationDocUrl,
    this.aadhaarDocUrl,
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
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'],
      fullName: json['fullName'],
      age: json['age'],
      phone: json['phone'],
      altPhone: json['altPhone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      languages: List<String>.from(json['languages']),
      religion: json['religion'],
      category: json['category'],
      education: json['education'] ?? 'Not Specified',
      experienceYears: json['experienceYears'],
      expectedSalary: json['expectedSalary'],
      workingHoursPerDay: json['workingHoursPerDay'],
      preferredWorkType: json['preferredWorkType'],
      status: CandidateStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CandidateStatus.newlyAdded,
      ),
      isMedicalCleared: json['isMedicalCleared'] ?? false,
      isPoliceVerified: json['isPoliceVerified'] ?? false,
      isAadhaarVerified: json['isAadhaarVerified'] ?? false,
      medicalClearanceDocUrl: json['medicalClearanceDocUrl'],
      policeVerificationDocUrl: json['policeVerificationDocUrl'],
      aadhaarDocUrl: json['aadhaarDocUrl'],
      photoUrl: json['photoUrl'] ?? '',
      currentPlacementId: json['currentPlacementId'],
      addedBy: json['addedBy'],
      dateAdded: DateTime.parse(json['dateAdded']),
      dateVerificationSent: json['dateVerificationSent'] != null ? DateTime.parse(json['dateVerificationSent']) : null,
      dateMedicalSent: json['dateMedicalSent'] != null ? DateTime.parse(json['dateMedicalSent']) : null,
      dateReadyToHire: json['dateReadyToHire'] != null ? DateTime.parse(json['dateReadyToHire']) : null,
      datePlaced: json['datePlaced'] != null ? DateTime.parse(json['datePlaced']) : null,
      availableFrom:
          json['availableFrom'] != null
              ? DateTime.parse(json['availableFrom'])
              : null,
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'phone': phone,
      'altPhone': altPhone,
      'address': address,
      'city': city,
      'state': state,
      'languages': languages,
      'religion': religion,
      'category': category,
      'education': education,
      'experienceYears': experienceYears,
      'expectedSalary': expectedSalary,
      'workingHoursPerDay': workingHoursPerDay,
      'preferredWorkType': preferredWorkType,
      'status': status.toString().split('.').last,
      'isMedicalCleared': isMedicalCleared,
      'isPoliceVerified': isPoliceVerified,
      'isAadhaarVerified': isAadhaarVerified,
      'medicalClearanceDocUrl': medicalClearanceDocUrl,
      'policeVerificationDocUrl': policeVerificationDocUrl,
      'aadhaarDocUrl': aadhaarDocUrl,
      'photoUrl': photoUrl,
      'currentPlacementId': currentPlacementId,
      'addedBy': addedBy,
      'dateAdded': dateAdded.toIso8601String(),
      'dateVerificationSent': dateVerificationSent?.toIso8601String(),
      'dateMedicalSent': dateMedicalSent?.toIso8601String(),
      'dateReadyToHire': dateReadyToHire?.toIso8601String(),
      'datePlaced': datePlaced?.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
      'remarks': remarks,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  CandidateModel copyWith({
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
    bool? isAadhaarVerified,
    String? medicalClearanceDocUrl,
    String? policeVerificationDocUrl,
    String? aadhaarDocUrl,
    String? photoUrl,
    String? currentPlacementId,
    DateTime? dateVerificationSent,
    DateTime? dateMedicalSent,
    DateTime? dateReadyToHire,
    DateTime? datePlaced,
    DateTime? availableFrom,
    String? remarks,
  }) {
    return CandidateModel(
      id: id,
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
      isAadhaarVerified: isAadhaarVerified ?? this.isAadhaarVerified,
      medicalClearanceDocUrl:
          medicalClearanceDocUrl ?? this.medicalClearanceDocUrl,
      policeVerificationDocUrl:
          policeVerificationDocUrl ?? this.policeVerificationDocUrl,
      aadhaarDocUrl: aadhaarDocUrl ?? this.aadhaarDocUrl,
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
    );
  }

  CandidateModel clearPlacement() {
    return CandidateModel(
      id: id, fullName: fullName, age: age, phone: phone, altPhone: altPhone,
      address: address, city: city, state: state, languages: languages,
      religion: religion, category: category, education: education,
      experienceYears: experienceYears, expectedSalary: expectedSalary,
      workingHoursPerDay: workingHoursPerDay, preferredWorkType: preferredWorkType,
      status: status, isMedicalCleared: isMedicalCleared,
      isPoliceVerified: isPoliceVerified, isAadhaarVerified: isAadhaarVerified,
      medicalClearanceDocUrl: medicalClearanceDocUrl,
      policeVerificationDocUrl: policeVerificationDocUrl,
      aadhaarDocUrl: aadhaarDocUrl, photoUrl: photoUrl,
      currentPlacementId: null, // CLEAR PLACEMENT
      addedBy: addedBy, dateAdded: dateAdded,
      dateVerificationSent: dateVerificationSent, dateMedicalSent: dateMedicalSent,
      dateReadyToHire: dateReadyToHire, datePlaced: datePlaced,
      availableFrom: availableFrom, remarks: remarks,
    );
  }

  @override
  String toString() =>
      'CandidateModel(id: $id, name: $fullName, status: ${status.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
