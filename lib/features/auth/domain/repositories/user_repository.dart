import '../entities/user_entity.dart';

/// Repository for user profile documents in Firestore (collection: users).
/// Auth state is handled by [AuthRepository]; this is for profile CRUD.
abstract class UserRepository {
  /// Fetches the user profile for [userId]. Returns null if not found.
  Future<UserEntity?> getProfile(String userId);

  /// Stream of the user profile for [userId].
  Stream<UserEntity?> watchProfile(String userId);

  /// Creates or overwrites the profile for [userId].
  Future<void> setProfile(UserEntity user);

  /// Updates display name and/or photo URL for [userId].
  Future<void> updateProfile(String userId, {String? displayName, String? photoUrl});
}
