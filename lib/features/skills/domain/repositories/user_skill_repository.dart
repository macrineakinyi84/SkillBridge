import '../entities/user_skill_entity.dart';

/// Repository for a user's skills (Firestore collection: user_skills).
abstract class UserSkillRepository {
  /// All skills linked to [userId].
  Future<List<UserSkillEntity>> getUserSkills(String userId);

  /// Stream of user skills for [userId].
  Stream<List<UserSkillEntity>> watchUserSkills(String userId);

  /// Get one user-skill by id.
  Future<UserSkillEntity?> getUserSkillById(String userSkillId);

  /// Add a skill for the user (creates user_skill document).
  Future<UserSkillEntity> addUserSkill(UserSkillEntity userSkill);

  /// Update a user's skill (e.g. proficiency, notes).
  Future<void> updateUserSkill(UserSkillEntity userSkill);

  /// Remove a skill from the user.
  Future<void> removeUserSkill(String userSkillId);
}
