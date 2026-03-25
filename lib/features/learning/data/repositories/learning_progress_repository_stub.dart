import '../../domain/repositories/learning_progress_repository.dart';

/// In-memory progress when Firestore is not available (e.g. Firebase not configured).
class LearningProgressRepositoryStub implements LearningProgressRepository {
  final Map<String, List<String>> _store = {};

  String _key(String userId, String pathId) => '$userId|$pathId';

  @override
  Future<List<String>> getCompletedResourceIds(String userId, String pathId) async {
    return List.from(_store[_key(userId, pathId)] ?? []);
  }

  @override
  Future<void> setCompletedResourceIds(String userId, String pathId, List<String> completedResourceIds) async {
    _store[_key(userId, pathId)] = List.from(completedResourceIds);
  }
}
