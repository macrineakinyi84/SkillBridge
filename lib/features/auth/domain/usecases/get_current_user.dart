import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Returns the current user if a session is persisted (e.g. after app restart).
/// Used to set initial auth state so the app doesn't flash the login screen.
class GetCurrentUser {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;

  UserEntity? call() => _repository.currentUser;
}
