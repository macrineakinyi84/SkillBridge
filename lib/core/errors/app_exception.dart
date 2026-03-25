// Thrown by data layer only; use cases catch and map to [Failure] so UI
// never depends on exception types and stays testable (see core/errors/failures.dart).
class AppException implements Exception {
  AppException([this.message]);

  final String? message;

  @override
  String toString() => message ?? 'AppException';
}

class NetworkException extends AppException {
  NetworkException([super.message]);
}

class AuthException extends AppException {
  AuthException([super.message]);
}
