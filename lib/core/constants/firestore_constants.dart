/// Firestore collection and field names. Use these for consistency and refactors.
class FirestoreConstants {
  FirestoreConstants._();

  // Collection names
  static const String users = 'users';
  static const String skills = 'skills';
  static const String userSkills = 'user_skills';
  static const String portfolios = 'portfolios';
  static const String learningProgress = 'learning_progress';
  static const String readinessScores = 'readiness_scores';

  // Common field names
  static const String id = 'id';
  static const String userId = 'userId';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}
