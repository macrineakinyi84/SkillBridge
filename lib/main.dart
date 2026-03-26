import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_init.dart';
import 'core/seed/seed_service.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/auth_scope.dart';
import 'features/auth/presentation/state/auth_notifier.dart';
import 'features/notifications/data/services/fcm_service.dart';
import 'core/auth/backend_session.dart';
import 'features/auth/domain/entities/user_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env from assets (use .env when present for local secrets; see README).
  await dotenv.load(fileName: 'assets/env.example');
  await HiveInit.ensureInitialized();
  final firebaseReady = await _initFirebase();
  await setupServiceLocator(useFirebase: firebaseReady);
  await sl<SeedService>().seedIfNeeded();
  await _restoreBackendSession();
  runApp(const SkillBridgeApp());
}

// Firebase init is best-effort so the app runs even without config (e.g. web);
// Auth falls back to stub and shows a message instead of crashing (see injection.dart).
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e) {
    debugPrint('Firebase init failed (app will run with stub auth): $e');
    return false;
  }
}

class SkillBridgeApp extends StatelessWidget {
  const SkillBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = sl<AuthNotifier>();
    final goRouter = AppRouter.createRouter(authNotifier);
    if (Firebase.apps.isNotEmpty) FcmService.initialize();

    return AuthScope(
      authNotifier: authNotifier,
      child: MaterialApp.router(
        title: 'SkillBridge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routerConfig: goRouter,
      ),
    );
  }
}

Future<void> _restoreBackendSession() async {
  final session = sl<BackendSession>();
  await session.restore();
  if (!session.state.isAuthenticated) return;

  // Restore auth state from persisted JWT (role is in claims, stored in secure storage).
  final claims = session.state.claims;
  final user = UserEntity.fromBackendClaims(claims);
  if (user.id.isNotEmpty) {
    sl<AuthNotifier>().setAuthenticated(user);
  }
}
