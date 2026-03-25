import 'package:flutter/foundation.dart';

import '../../../../core/auth/backend_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_auth_state.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    required GetAuthState getAuthState,
    required GetCurrentUser getCurrentUser,
    required SignIn signIn,
    required SignOut signOut,
    required SignUp signUp,
    BackendSession? backendSession,
  })  : _getAuthState = getAuthState,
        _getCurrentUser = getCurrentUser,
        _signIn = signIn,
        _signOut = signOut,
        _signUp = signUp,
        _backendSession = backendSession {
    _setInitialStateFromPersistedSession();
    _listenToAuthState();
  }

  final GetAuthState _getAuthState;
  final GetCurrentUser _getCurrentUser;
  final SignIn _signIn;
  final SignOut _signOut;
  final SignUp _signUp;
  final BackendSession? _backendSession;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  /// Set authenticated state explicitly (used for backend JWT auth flows).
  void setAuthenticated(UserEntity user) {
    _state = AuthState(status: AuthStatus.authenticated, user: user);
    notifyListeners();
  }

  void setUnauthenticated() {
    _state = const AuthState(status: AuthStatus.unauthenticated);
    notifyListeners();
  }

  /// Restore state from persisted session (Firebase Auth stores session automatically).
  void _setInitialStateFromPersistedSession() {
    final user = _getCurrentUser.call();
    if (user != null) {
      _state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    }
  }

  void _listenToAuthState() {
    _getAuthState.call.listen((user) {
      _state = AuthState(
        status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: user,
      );
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _state = _state.copyWith(status: AuthStatus.loading, message: null);
    notifyListeners();
    final result = await _signIn.call(email: email, password: password);
    result.fold(
      (msg) {
        _state = _state.copyWith(status: AuthStatus.failure, message: msg);
        notifyListeners();
      },
      (_) {
        _state = _state.copyWith(status: AuthStatus.authenticated);
        notifyListeners();
      },
    );
  }

  Future<void> signUp(String email, String password, {String? displayName}) async {
    _state = _state.copyWith(status: AuthStatus.loading, message: null);
    notifyListeners();
    final result = await _signUp.call(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (msg) {
        _state = _state.copyWith(status: AuthStatus.failure, message: msg);
        notifyListeners();
      },
      (_) {
        _state = _state.copyWith(status: AuthStatus.authenticated);
        notifyListeners();
      },
    );
  }

  Future<void> signOut() async {
    await _signOut.call();
    await _backendSession?.clear();
    _state = const AuthState(status: AuthStatus.unauthenticated);
    notifyListeners();
  }
}
