import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../domain/repositories/learning_progress_repository.dart';

/// Persists path progress in Firestore: users/{userId}/learning_progress/{pathId}.
/// Falls back to empty list / no-op if Firestore is unavailable.
class LearningProgressRepositoryImpl implements LearningProgressRepository {
  LearningProgressRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _progressRef(String userId) =>
      _firestore.collection(FirestoreConstants.users).doc(userId).collection(FirestoreConstants.learningProgress);

  @override
  Future<List<String>> getCompletedResourceIds(String userId, String pathId) async {
    try {
      final doc = await _progressRef(userId).doc(pathId).get();
      if (!doc.exists || doc.data() == null) return [];
      final list = doc.data()!['completedResourceIds'];
      if (list is! List) return [];
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> setCompletedResourceIds(String userId, String pathId, List<String> completedResourceIds) async {
    try {
      await _progressRef(userId).doc(pathId).set({
        'pathId': pathId,
        'completedResourceIds': completedResourceIds,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Ignore when Firestore is unavailable
    }
  }
}
