import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/skill_entity.dart';
import '../../../../core/constants/firestore_constants.dart';

/// Firestore document model for a skill (collection: skills).
class SkillModel {
  const SkillModel({
    required this.id,
    required this.name,
    this.category,
    this.proficiencyLevel,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? category;
  final String? proficiencyLevel;
  final String? notes;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FirestoreConstants.id: id,
      'name': name,
      'category': category,
      'proficiencyLevel': proficiencyLevel,
      'notes': notes,
      FirestoreConstants.createdAt: createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  static SkillModel fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json[FirestoreConstants.id] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      notes: json['notes'] as String?,
      createdAt: _parseTimestamp(json[FirestoreConstants.createdAt]),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  SkillEntity toEntity() => SkillEntity(
        id: id,
        name: name,
        category: category,
        proficiencyLevel: proficiencyLevel,
        notes: notes,
      );

  static SkillModel fromEntity(SkillEntity entity, {DateTime? createdAt}) {
    return SkillModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      proficiencyLevel: entity.proficiencyLevel,
      notes: entity.notes,
      createdAt: createdAt,
    );
  }
}
