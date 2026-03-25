import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

/// Auth repository (clean architecture): single abstraction for auth operations.
/// Implemented in the data layer with Firebase Auth.
/// Supports: email/password signup, login, logout, session persistence.
abstract class AuthRepository {
  /// Stream of auth state; use for reactive UI. Emits current user when session is restored.
  Stream<UserEntity?> get authStateChanges;
  /// Current user if session is persisted (e.g. after app cold start).
  UserEntity? get currentUser;

  Future<Either<String, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<String, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<String, void>> signOut();
}
