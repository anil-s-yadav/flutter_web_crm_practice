import 'package:equatable/equatable.dart';

enum LearningCategory {
  salesPitch,
  objectionHandling,
  serviceScope,
  sourcingVerification,
  fieldSop,
}

extension LearningCategoryExtension on LearningCategory {
  String get displayName {
    switch (this) {
      case LearningCategory.salesPitch:
        return 'Sales Pitch & Calling Scripts';
      case LearningCategory.objectionHandling:
        return 'Client Objections & Rebuttals';
      case LearningCategory.serviceScope:
        return '8 Services Scope & Duties';
      case LearningCategory.sourcingVerification:
        return 'Sourcing & Verification SOP';
      case LearningCategory.fieldSop:
        return 'Field Executive SOP';
    }
  }

  String get shortName {
    switch (this) {
      case LearningCategory.salesPitch:
        return 'Sales Pitch';
      case LearningCategory.objectionHandling:
        return 'Objections';
      case LearningCategory.serviceScope:
        return 'Service Scope';
      case LearningCategory.sourcingVerification:
        return 'Sourcing';
      case LearningCategory.fieldSop:
        return 'Field SOP';
    }
  }

  static LearningCategory fromString(String val) {
    return LearningCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => LearningCategory.salesPitch,
    );
  }
}

class LearningTopicModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final LearningCategory category;
  final String targetRole;
  final String? scriptEnglish;
  final String? scriptHindi;
  final String? keyTip;
  final List<String> bulletPoints;
  final List<String> tags;
  final int orderIndex;
  final bool isActive;

  const LearningTopicModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.targetRole = 'all',
    this.scriptEnglish,
    this.scriptHindi,
    this.keyTip,
    this.bulletPoints = const [],
    this.tags = const [],
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory LearningTopicModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return LearningTopicModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      category: LearningCategoryExtension.fromString(
        json['category']?.toString() ?? 'salesPitch',
      ),
      targetRole: json['target_role']?.toString() ?? json['targetRole']?.toString() ?? 'all',
      scriptEnglish: json['script_english']?.toString() ?? json['scriptEnglish']?.toString(),
      scriptHindi: json['script_hindi']?.toString() ?? json['scriptHindi']?.toString(),
      keyTip: json['key_tip']?.toString() ?? json['keyTip']?.toString(),
      bulletPoints: parseList(json['bullet_points'] ?? json['bulletPoints']),
      tags: parseList(json['tags']),
      orderIndex: int.tryParse(json['order_index']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category.name,
      'target_role': targetRole,
      'script_english': scriptEnglish,
      'script_hindi': scriptHindi,
      'key_tip': keyTip,
      'bullet_points': bulletPoints,
      'tags': tags,
      'order_index': orderIndex,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        category,
        targetRole,
        scriptEnglish,
        scriptHindi,
        keyTip,
        bulletPoints,
        tags,
        orderIndex,
        isActive,
      ];
}
