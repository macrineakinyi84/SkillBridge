import 'package:get_it/get_it.dart';

import '../auth/backend_session.dart';
import '../network/backend_api_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/auth_repository_stub.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_auth_state.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/state/auth_notifier.dart';
import '../../features/readiness/domain/models/readiness_score_config.dart';
import '../../features/readiness/domain/services/readiness_score_calculator.dart';
import '../../features/readiness/domain/usecases/calculate_readiness_score.dart';
import '../../features/employer/data/datasources/employer_remote_datasource.dart';
import '../../features/employer/data/datasources/employer_remote_datasource_hybrid.dart';
import '../../features/employer/domain/repositories/employer_repository.dart';
import '../../features/employer/data/repositories/employer_repository_impl.dart';
import '../../features/gamification/data/datasources/gamification_remote_datasource.dart';
import '../../features/gamification/domain/repositories/gamification_repository.dart';
import '../../features/gamification/data/repositories/gamification_repository_impl.dart';
import '../../features/assessment/data/datasources/assessment_remote_datasource.dart';
import '../../features/assessment/domain/repositories/assessment_repository.dart';
import '../../features/assessment/data/repositories/assessment_repository_impl.dart';
import '../../features/learning/domain/repositories/learning_progress_repository.dart';
import '../../features/learning/data/repositories/learning_progress_repository_impl.dart';
import '../../features/learning/data/repositories/learning_progress_repository_stub.dart';
import '../../features/community/data/datasources/community_remote_datasource.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/student_data/data/repositories/student_portfolio_repository.dart';
import '../../features/student_data/data/repositories/student_skills_repository.dart';
import '../seed/seed_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator({bool useFirebase = true}) async {
  sl.registerLazySingleton<BackendSession>(() => BackendSession());

  // Stub used when Firebase init fails (e.g. web without config) so app still runs;
  // real impl: AuthRepositoryImpl (see auth/data/repositories/auth_repository_impl.dart).
  sl.registerLazySingleton<AuthRepository>(
    () => useFirebase ? AuthRepositoryImpl() : AuthRepositoryStub(),
  );
  sl.registerLazySingleton(() => GetAuthState(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerFactory(() => AuthNotifier(
        getAuthState: sl(),
        getCurrentUser: sl(),
        signIn: sl(),
        signOut: sl(),
        signUp: sl(),
        backendSession: sl(),
      ));

  // Calculator is configurable so we can A/B test weights without code changes
  // (e.g. ReadinessScoreConfig.researchSkillsHeavy in readiness/domain/models/readiness_score_config.dart).
  sl.registerLazySingleton<ReadinessScoreCalculator>(
    () => ReadinessScoreCalculator(config: ReadinessScoreConfig.researchDefault),
  );
  sl.registerLazySingleton(() => CalculateReadinessScore(sl()));

  // Employer: backend-first with safe fallback to mock for unimplemented endpoints/offline.
  sl.registerLazySingleton<EmployerRemoteDataSource>(() => EmployerRemoteDataSourceHybrid(
        backend: EmployerRemoteDataSourceBackend(),
        fallback: EmployerRemoteDataSourceMock(),
      ));
  sl.registerLazySingleton<EmployerRepository>(() => EmployerRepositoryImpl(sl()));

  // Gamification: XP, badges, streaks, career health; mock until backend (see gamification/data/datasources).
  sl.registerLazySingleton<GamificationRemoteDataSource>(() => GamificationRemoteDataSourceMock());
  sl.registerLazySingleton<GamificationRepository>(() => GamificationRepositoryImpl(sl()));

  sl.registerLazySingleton(() => BackendApiClient(sl()));
  sl.registerLazySingleton<AssessmentRemoteDataSourceMock>(() => AssessmentRemoteDataSourceMock());
  sl.registerLazySingleton<AssessmentRemoteDataSource>(
    () => AssessmentRemoteDataSourceBackend(sl(), sl()),
  );
  sl.registerLazySingleton<AssessmentRepository>(() => AssessmentRepositoryImpl(sl()));

  // Learning: path progress persisted in Firestore when useFirebase is true.
  sl.registerLazySingleton<LearningProgressRepository>(
    () => useFirebase ? LearningProgressRepositoryImpl() : LearningProgressRepositoryStub(),
  );

  // Community: feed, leaderboard, challenges; mock until backend (see community/data/datasources).
  sl.registerLazySingleton<CommunityRemoteDataSource>(() => CommunityRemoteDataSourceMock());
  sl.registerLazySingleton<CommunityRepository>(() => CommunityRepositoryImpl(sl()));

  // Notifications: center + FCM; local mock until backend (see notifications/data/datasources).
  sl.registerLazySingleton<NotificationLocalDataSource>(() => NotificationLocalDataSourceMock());
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(sl()));

  // Student local persistence (Hive-backed).
  sl.registerLazySingleton(() => StudentSkillsRepository());
  sl.registerLazySingleton(() => StudentPortfolioRepository());

  // One-time seeding (Kenyan-realistic). Safe to call on every startup.
  sl.registerLazySingleton(() => SeedService(skillsRepo: sl(), portfolioRepo: sl()));
}
