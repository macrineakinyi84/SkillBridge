/// Persists which path resources a user has completed (e.g. Firestore).
abstract class LearningProgressRepository {
  /// Completed resource IDs for this user and path.
  Future<List<String>> getCompletedResourceIds(String userId, String pathId);

  /// Save completed resource IDs (replaces existing for this path).
  Future<void> setCompletedResourceIds(String userId, String pathId, List<String> completedResourceIds);
}
