import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/backend_session.dart';
import '../config/env_config.dart';

/// Authenticated HTTP client for backend API. Attaches JWT from [BackendSession].
/// Use for protected endpoints (e.g. /api/assessments/score, /api/users/me).
class BackendApiClient {
  BackendApiClient(this._session);

  final BackendSession _session;

  String get _baseUrl => EnvConfig.backendBaseUrl;
  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  String? get _token => _session.state.token;

  bool get isAuthenticated => _session.state.isAuthenticated;

  /// Throws if no token (caller should handle 401 / unauthenticated).
  void _ensureToken() {
    if (_token == null || _token!.isEmpty) {
      throw BackendApiException('Not authenticated', 401);
    }
  }

  Map<String, String> _authHeaders() {
    _ensureToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_token!}',
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(_uri(path), headers: _authHeaders());
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: _authHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  /// POST and return raw bytes (e.g. PDF). Throws on non-2xx.
  Future<List<int>> postBinary(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: _authHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw BackendApiException(
        _extractError(res.body) ?? 'Request failed',
        res.statusCode,
      );
    }
    return res.bodyBytes;
  }

  static String? _extractError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final err = json['error'];
      if (err is Map && err['message'] is String) return err['message'] as String;
      if (json['message'] is String) return json['message'] as String;
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    final body = res.body;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body.isEmpty) return {};
      try {
        return (jsonDecode(body) as Map).cast<String, dynamic>();
      } catch (_) {
        throw BackendApiException('Invalid JSON response', res.statusCode);
      }
    }
    String? message;
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final err = json['error'];
      if (err is Map && err['message'] is String) message = err['message'] as String;
      if (json['message'] is String) message = json['message'] as String;
    } catch (_) {}
    throw BackendApiException(message ?? 'Request failed', res.statusCode);
  }
}

class BackendApiException implements Exception {
  BackendApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'BackendApiException($statusCode): $message';
}
