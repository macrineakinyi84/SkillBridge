import '../entities/readiness_entity.dart';

/// Repository for readiness score (Firestore collection: readiness_scores, doc id = userId).
abstract class ReadinessScoreRepository {
  /// Get the current readiness score for [userId]. Returns null if not set.
  Future<ReadinessEntity?> getReadinessScore(String userId);

  /// Stream of readiness score for [userId].
  Stream<ReadinessEntity?> watchReadinessScore(String userId);

  /// Set or update the readiness score for [userId] (one document per user).
  Future<void> setReadinessScore(String userId, ReadinessEntity score);
}
