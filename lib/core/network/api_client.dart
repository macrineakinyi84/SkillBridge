/// Central HTTP client (e.g. Dio) configuration and interceptors.
// All outbound API calls go through this client so auth (JWT) and error mapping
// apply in one place; feature datasources receive an injected instance (see injection.dart).
// Example:
// class ApiClient {
//   ApiClient({required this.baseUrl});
//   final String baseUrl;
//   Dio get dio => _dio ??= _createDio();
//   Dio? _dio;
//   Dio _createDio() => Dio(BaseOptions(baseUrl: baseUrl))..interceptors.addAll([...]);
// }
