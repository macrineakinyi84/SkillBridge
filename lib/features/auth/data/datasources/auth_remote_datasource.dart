import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// Remote auth API (Firebase Auth).
/// Session persistence: Firebase Auth persists the session automatically
/// (e.g. Android Keystore / iOS Keychain). [authStateChanges] and [currentUser]
/// reflect the restored session after app restart.
abstract class AuthRemoteDataSource {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<UserEntity?> get authStateChanges =>
      _auth.authStateChanges().map(_userToEntity);

  @override
  UserEntity? get currentUser => _userToEntity(_auth.currentUser);

  static UserEntity? _userToEntity(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: UserRole.student,
    );
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final entity = _userToEntity(cred.user);
    if (entity == null) throw Exception('Sign in failed');
    return entity;
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null && displayName != null && displayName.isNotEmpty) {
      await cred.user!.updateDisplayName(displayName);
    }
    final entity = _userToEntity(cred.user);
    if (entity == null) throw Exception('Sign up failed');
    return entity;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
