import 'dart:convert';

enum MaidStatus {
  newlyAdded,
  verificationPending,
  medicalPending,
  readyToPlace,
  placed,
  blacklisted,
}

extension MaidStatusExtension on MaidStatus {
  String get displayName {
    switch (this) {
      case MaidStatus.newlyAdded:
        return 'Newly Added';
      case MaidStatus.verificationPending:
        return 'Verification Pending';
      case MaidStatus.medicalPending:
        return 'Medical Pending';
      case MaidStatus.readyToPlace:
        return 'Ready to Place';
      case MaidStatus.placed:
        return 'Placed';
      case MaidStatus.blacklisted:
        return 'Blacklisted';
    }
  }

  static MaidStatus fromString(String value) {
    return MaidStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MaidStatus.newlyAdded,
    );
  }
}

class MaidModel {
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
  final MaidStatus status;

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
  final DateTime? availableFrom;
  final String? remarks;

  MaidModel({
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
    this.availableFrom,
    this.remarks,
  });

  factory MaidModel.fromJson(Map<String, dynamic> json) {
    return MaidModel(
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
      status: MaidStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MaidStatus.newlyAdded,
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
      'availableFrom': availableFrom?.toIso8601String(),
      'remarks': remarks,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  MaidModel copyWith({
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
    MaidStatus? status,
    bool? isMedicalCleared,
    bool? isPoliceVerified,
    bool? isAadhaarVerified,
    String? medicalClearanceDocUrl,
    String? policeVerificationDocUrl,
    String? aadhaarDocUrl,
    String? photoUrl,
    String? currentPlacementId,
    DateTime? availableFrom,
    String? remarks,
  }) {
    return MaidModel(
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
      availableFrom: availableFrom ?? this.availableFrom,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  String toString() =>
      'MaidModel(id: $id, name: $fullName, status: ${status.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaidModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
