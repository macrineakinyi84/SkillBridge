import 'dart:async';
import 'dart:convert';

import 'token_storage.dart';

class BackendSession {
  BackendSession({TokenStorage? storage})
      : _storage = storage ?? createTokenStorage();

  static const _tokenKey = 'skillbridge.jwt';

  final TokenStorage _storage;
  final StreamController<BackendSessionState> _controller =
      StreamController<BackendSessionState>.broadcast();

  BackendSessionState _state = const BackendSessionState();
  BackendSessionState get state => _state;
  Stream<BackendSessionState> get changes => _controller.stream;

  Future<void> restore() async {
    final token = await _storage.read(_tokenKey);
    if (token == null || token.isEmpty) {
      _emit(const BackendSessionState());
      return;
    }
    _emit(BackendSessionState(token: token, claims: _decodeClaims(token)));
  }

  Future<void> setToken(String token) async {
    await _storage.write(_tokenKey, token);
    _emit(BackendSessionState(token: token, claims: _decodeClaims(token)));
  }

  Future<void> clear() async {
    await _storage.delete(_tokenKey);
    _emit(const BackendSessionState());
  }

  void _emit(BackendSessionState s) {
    _state = s;
    _controller.add(s);
  }

  Map<String, dynamic> _decodeClaims(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return {};
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      return (jsonDecode(decoded) as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }
}

class BackendSessionState {
  const BackendSessionState({this.token, this.claims = const {}});

  final String? token;
  final Map<String, dynamic> claims;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  /// Role from JWT payload; persisted as part of the token in secure storage.
  String? get role => claims['role'] as String?;
}

