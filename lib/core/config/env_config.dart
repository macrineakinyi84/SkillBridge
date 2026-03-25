import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central access to env-based config. Never hardcode secrets in the app.
///
/// Load .env via flutter_dotenv in main (from assets/env.example or your local .env).
/// For production, use --dart-define-from-file or CI-injected env.
class EnvConfig {
  EnvConfig._();

  /// Stripe secret/publishable key. Use dotenv.env['STRIPE_KEY'].
  /// Example: final stripeKey = dotenv.env['STRIPE_KEY'] ?? '';
  static String? get stripeKey => dotenv.env['STRIPE_KEY'];

  /// Backend API base URL. Example: https://api.skillupkenya.com
  static String? get apiBaseUrl => dotenv.env['API_BASE_URL'];

  /// Resolved backend base URL (env or default). Backend default port is 4000.
  static String get backendBaseUrl {
    final fromEnv = apiBaseUrl;
    if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  /// Optional: get required key or throw in debug.
  static String getStripeKeyOrThrow() {
    final key = dotenv.env['STRIPE_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError(
        'STRIPE_KEY is not set. Copy assets/env.example to .env and add your key, '
        'or use --dart-define-from-file for production.',
      );
    }
    return key;
  }
}
