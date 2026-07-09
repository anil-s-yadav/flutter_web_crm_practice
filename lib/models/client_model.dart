import 'dart:convert';

enum ClientStatus {
  newInquiry,
  followUp,
  noResponse,
  notInterested,
  converted,
  active,
  churned
}

extension ClientStatusExtension on ClientStatus {
  String get displayName {
    switch (this) {
      case ClientStatus.newInquiry:
        return 'New Inquiry';
      case ClientStatus.followUp:
        return 'Follow Up';
      case ClientStatus.noResponse:
        return 'No Response';
      case ClientStatus.notInterested:
        return 'Not Interested';
      case ClientStatus.converted:
        return 'Converted';
      case ClientStatus.active:
        return 'Active';
      case ClientStatus.churned:
        return 'Churned';
    }
  }

  static ClientStatus fromString(String value) {
    return ClientStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClientStatus.newInquiry
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
  final String source;
  final DateTime inquiryDate;
  final String? remarks;

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
    required this.source,
    required this.inquiryDate,
    this.remarks
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      altPhone: json['altPhone'] as String?,
      email: json['email'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      locality: json['locality'] as String,
      houseType: json['houseType'] as String,
      familySize: json['familySize'] as int,
      hasPets: (json['hasPets'] as bool?) ?? false,
      petDetails: json['petDetails'] as String?,
      hasElderlyMembers: (json['hasElderlyMembers'] as bool?) ?? false,
      hasChildren: (json['hasChildren'] as bool?) ?? false,
      childrenCount: json['childrenCount'] as int?,
      preferredCandidateCategory: json['preferredCandidateCategory'] as String,
      requiredSkills: List<String>.from(json['requiredSkills'] as List),
      budgetRange: json['budgetRange'] as String,
      status: ClientStatusExtension.fromString(json['status'] as String),
      assignedEmployeeId: json['assignedEmployeeId'] as String?,
      source: json['source'] as String,
      inquiryDate: DateTime.parse(json['inquiryDate'] as String),
      remarks: json['remarks'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'altPhone': altPhone,
      'email': email,
      'address': address,
      'city': city,
      'locality': locality,
      'houseType': houseType,
      'familySize': familySize,
      'hasPets': hasPets,
      'petDetails': petDetails,
      'hasElderlyMembers': hasElderlyMembers,
      'hasChildren': hasChildren,
      'childrenCount': childrenCount,
      'preferredCandidateCategory': preferredCandidateCategory,
      'requiredSkills': requiredSkills,
      'budgetRange': budgetRange,
      'status': status.name,
      'assignedEmployeeId': assignedEmployeeId,
      'source': source,
      'inquiryDate': inquiryDate.toIso8601String(),
      'remarks': remarks
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
    String? source,
    DateTime? inquiryDate,
    String? remarks
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
      source: source ?? this.source,
      inquiryDate: inquiryDate ?? this.inquiryDate,
      remarks: remarks ?? this.remarks
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
