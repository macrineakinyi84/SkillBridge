import 'package:equatable/equatable.dart';

/// A user's association with a skill (proficiency, notes).
class UserSkillEntity extends Equatable {
  const UserSkillEntity({
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

  @override
  List<Object?> get props => [id, userId, skillId, skillName, proficiencyLevel, notes, createdAt];
}
