import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../domain/repositories/notification_repository.dart';

/// FCM: request permission, foreground banner, background handled by system, tap -> deep link via GoRouter.
class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request permission. Call on onboarding step 5 or first dashboard load. No-op on web so onboarding can proceed.
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  static bool _initialized = false;

  /// Initialize: get token, subscribe to foreground, background, and tap. Call once after router is set.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final token = await _messaging.getToken();
    if (token != null) {
      final repo = sl<NotificationRepository>();
      await repo.saveFcmToken(token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      sl<NotificationRepository>().saveFcmToken(newToken);
    });

    // Foreground: show in-app (caller can show a banner via stream or overlay).
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // In-app banner can be shown by listening to a stream that NotificationScope provides.
      _foregroundMessageController.add(message);
    });

    // Background message handler must be top-level.
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Tap when app is in background or terminated.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  static final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  static Stream<RemoteMessage> get foregroundMessages => _foregroundMessageController.stream;

  static void _handleNotificationTap(RemoteMessage message) {
    final payload = message.data;
    final type = payload['type'] as String?;
    final context = router.AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    if (type == 'job_match' || type == 'application_status') {
      final jobId = payload['jobId'] as String?;
      if (jobId != null) context.push('${router.AppRouter.jobBoard}/job/$jobId');
      return;
    }
    if (type == 'badge_earned' || type == 'level_up') {
      context.push(router.AppRouter.profile);
      return;
    }
    if (type == 'micro_lesson' || type == 'learning_reminder') {
      context.push(router.AppRouter.learningHub);
      return;
    }
    context.push(router.AppRouter.notifications);
  }

  static void dispose() {
    _foregroundMessageController.close();
  }
}

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Optional: persist notification locally when received in background.
}
