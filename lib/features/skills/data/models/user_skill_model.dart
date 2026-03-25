import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_skill_entity.dart';
import '../../../../core/constants/firestore_constants.dart';

/// Firestore document model for user_skills collection.
class UserSkillModel {
  const UserSkillModel({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.skillName,
    this.proficiencyLevel,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String skillId;
  final String skillName;
  final String? proficiencyLevel;
  final String? notes;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FirestoreConstants.id: id,
      FirestoreConstants.userId: userId,
      'skillId': skillId,
      'skillName': skillName,
      'proficiencyLevel': proficiencyLevel,
      'notes': notes,
      FirestoreConstants.createdAt: createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  static UserSkillModel fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      id: json[FirestoreConstants.id] as String? ?? '',
      userId: json[FirestoreConstants.userId] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      skillName: json['skillName'] as String? ?? '',
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

  UserSkillEntity toEntity() => UserSkillEntity(
        id: id,
        userId: userId,
        skillId: skillId,
        skillName: skillName,
        proficiencyLevel: proficiencyLevel,
        notes: notes,
        createdAt: createdAt,
      );

  static UserSkillModel fromEntity(UserSkillEntity entity) {
    return UserSkillModel(
      id: entity.id,
      userId: entity.userId,
      skillId: entity.skillId,
      skillName: entity.skillName,
      proficiencyLevel: entity.proficiencyLevel,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
