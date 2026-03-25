import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Stub auth repository when Firebase is not configured (e.g. web without config).
/// Prevents "No Firebase App" crash; auth actions return a helpful message.
class AuthRepositoryStub implements AuthRepository {
  static const String _message =
      'Firebase is not configured. Add Firebase options for web (see README).';

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(null);

  @override
  UserEntity? get currentUser => null;

  @override
  Future<Either<String, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => left(_message);

  @override
  Future<Either<String, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async => left(_message);

  @override
  Future<Either<String, void>> signOut() async => right(null);
}
