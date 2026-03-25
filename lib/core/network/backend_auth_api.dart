import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env_config.dart';

class BackendAuthApi {
  BackendAuthApi._();

  static Uri _uri(String path) => Uri.parse('${EnvConfig.backendBaseUrl}$path');

  /// Returns the OTP if the backend includes it (dev only). Otherwise null.
  /// Optionally pass a role when creating a new user ("student"|"employer").
  static Future<String?> requestOtp({required String email, String? role}) async {
    final res = await http.post(
      _uri('/api/auth/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res.body) ?? 'Failed to request OTP.');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final otp = data['otp'] as String?;
    return otp;
  }

  static Future<VerifyOtpResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      _uri('/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res.body) ?? 'OTP verification failed.');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final token = data['token'] as String?;
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? {};
    if (token == null || token.isEmpty) throw Exception('Missing token from server.');
    return VerifyOtpResponse(token: token, user: user);
  }

  /// GET /api/assessments/categories (no auth)
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await http.get(_uri('/api/assessments/categories'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res.body) ?? 'Failed to load categories');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = json['data'];
    if (data is! List) return [];
    return (data as List).map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  /// GET /api/assessments/categories/:categoryId/questions (no auth)
  static Future<List<Map<String, dynamic>>> getQuestions(String categoryId) async {
    final res = await http.get(_uri('/api/assessments/categories/$categoryId/questions'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractError(res.body) ?? 'Failed to load questions');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = json['data'];
    if (data is! List) return [];
    return (data as List).map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static String? _extractError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'];
      if (error is Map && error['message'] is String) return error['message'] as String;
      if (json['message'] is String) return json['message'] as String;
      if (json['error'] is String) return json['error'] as String;
      return null;
    } catch (_) {
      return null;
    }
  }
}

class VerifyOtpResponse {
  const VerifyOtpResponse({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;
}

