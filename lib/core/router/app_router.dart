import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../shared/widgets/employer_shell.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/state/auth_notifier.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/skills/presentation/pages/skills_page.dart';
import '../../features/skills/presentation/pages/skills_categories_page.dart';
import '../../features/skills/presentation/pages/skill_assess_page.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/readiness/presentation/pages/readiness_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/jobs/presentation/pages/job_board_page.dart';
import '../../features/learning/presentation/screens/learning_hub_screen.dart';
import '../../features/learning/presentation/screens/learning_path_screen.dart';
import '../../features/learning/presentation/screens/micro_lesson_screen.dart';
import '../../features/learning/presentation/screens/learning_path_certificate_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/portfolio/presentation/screens/cv_preview_screen.dart';
import '../../features/skills/presentation/pages/skill_results_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../features/jobs/presentation/pages/application_tracker_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/employer/presentation/pages/manage_listings_page.dart';
import '../../features/employer/presentation/screens/employer_dashboard_screen.dart';
import '../../features/employer/presentation/screens/post_job_screen.dart';
import '../../features/employer/presentation/screens/talent_pipeline_screen.dart';
import '../../features/employer/presentation/screens/candidate_profile_screen.dart';
import '../../features/employer/presentation/screens/candidate_profile_by_user_id_screen.dart';
import '../../features/employer/presentation/screens/candidate_full_portfolio_screen.dart';
import '../../features/employer/presentation/screens/talent_pool_page.dart';
import '../../features/assessment/presentation/screens/assessment_list_screen.dart';
import '../../features/assessment/presentation/screens/assessment_quiz_screen.dart';
import '../../features/assessment/presentation/screens/assessment_result_screen.dart';
import '../../features/assessment/domain/models/assessment_result.dart' as models;
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/community/presentation/screens/peer_challenge_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String dashboard = '/dashboard';
  static const String skills = '/skills';
  static const String portfolio = '/portfolio';
  static const String cvPreview = '/portfolio/preview';
  static const String profile = '/profile';
  static const String readiness = '/readiness';
  static const String jobBoard = '/job-board';
  static const String learningHub = '/learning-hub';
  static String learningPath(String pathId) => '$learningHub/path/$pathId';
  static String microLesson(String lessonId) => '$learningHub/lesson/$lessonId';
  static String learningPathCertificate(String pathId, [String? pathTitle]) => '$learningHub/certificate/$pathId';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String messages = '/messages';

  // Employer (S-020–S-025)
  static const String employerDashboard = '/employer/dashboard';
  static const String employerListings = '/employer/listings';
  static const String employerPostJob = '/employer/listings/post-job';
  static String employerPostJobEdit(String id) => '/employer/listings/edit/$id';
  static const String employerCandidatesPath = '/employer/candidates';
  static String employerCandidates(String jobId) => '/employer/candidates/$jobId';
  static const String employerCandidatePath = '/employer/candidate';
  static String employerCandidate(String applicationId) => '/employer/candidate/$applicationId';
  static String employerCandidatePortfolio(String userId) => '/employer/candidate-portfolio/$userId';

  static const String assessmentList = '/assessment';
  static const String assessmentQuiz = '/assessment/quiz';
  static String assessmentQuizFor(String categoryId) => '/assessment/quiz/$categoryId';
  static const String assessmentResult = '/assessment/result';

  static const String community = '/community';
  static const String communityChallenge = '/community/challenge';

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter([AuthNotifier? authNotifier]) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: splash,
      refreshListenable: authNotifier ?? _NoOpListenable(),
      redirect: (context, state) {
        if (authNotifier == null) return null;
        final status = authNotifier.state.status;
        final path = state.uri.path;
        final role = authNotifier.state.user?.role ?? UserRole.student;
        final isPublic = path == splash || path == onboarding || path == login || path == register || path == forgotPassword || path == verifyOtp;

        if (status == AuthStatus.authenticated && (path == splash || path == onboarding || path == login || path == register)) {
          final next = state.uri.queryParameters['next'];
          if (next != null && next.isNotEmpty) return next;
          return role == UserRole.employer ? employerDashboard : dashboard;
        }
        if (status != AuthStatus.authenticated && status != AuthStatus.initial && !isPublic) return login;

        // Role-based: students must not see employer area; employers must not see student shell.
        if (status == AuthStatus.authenticated) {
          if (role == UserRole.student && path.startsWith('/employer')) return dashboard;
          if (role == UserRole.employer && (path == dashboard || path.startsWith('/skills') || path.startsWith('/portfolio') || path == profile)) return employerDashboard;
        }
        return null;
      },
      routes: [
        GoRoute(path: splash, builder: (_, __) => const SplashPage()),
        GoRoute(path: onboarding, builder: (_, __) => const OnboardingPage()),
        GoRoute(path: login, builder: (_, __) => const LoginPage()),
        GoRoute(path: register, builder: (_, __) => const RegisterPage()),
        GoRoute(path: forgotPassword, builder: (_, __) => const ForgotPasswordPage()),
        GoRoute(path: readiness, builder: (_, __) => const ReadinessPage()),
        GoRoute(path: verifyOtp, builder: (_, state) => VerifyOtpPage(email: state.uri.queryParameters['email'], otp: state.uri.queryParameters['otp'])),
        GoRoute(path: messages, builder: (_, __) => const MessagesPage()),
        GoRoute(
          path: jobBoard,
          builder: (_, __) => const JobBoardPage(),
          routes: [
            GoRoute(path: 'job/:jobId', builder: (_, state) => JobDetailPage(jobId: state.pathParameters['jobId'])),
            GoRoute(path: 'applications', builder: (_, __) => const ApplicationTrackerPage()),
          ],
        ),
        GoRoute(
          path: learningHub,
          builder: (_, __) => const LearningHubScreen(),
          routes: [
            GoRoute(path: 'path/:pathId', builder: (_, state) => LearningPathScreen(pathId: state.pathParameters['pathId']!)),
            GoRoute(path: 'lesson/:lessonId', builder: (_, state) => MicroLessonScreen(lessonId: state.pathParameters['lessonId']!)),
            GoRoute(
              path: 'certificate/:pathId',
              builder: (_, state) => LearningPathCertificateScreen(
                pathId: state.pathParameters['pathId']!,
                pathTitle: state.extra as String? ?? 'Learning Path',
              ),
            ),
          ],
        ),
        GoRoute(path: notifications, builder: (_, __) => const NotificationCenterScreen()),
        GoRoute(path: settings, builder: (_, __) => const SettingsPage()),
        GoRoute(path: cvPreview, builder: (_, __) => const CvPreviewScreen()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => EmployerShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/employer/dashboard', builder: (_, __) => const EmployerDashboardScreen())]),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/employer/listings',
                  builder: (_, __) => const ManageListingsPage(),
                  routes: [
                    GoRoute(
                      path: 'post-job',
                      builder: (_, __) => const PostJobScreen(),
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      builder: (_, state) => PostJobScreen(editListingId: state.pathParameters['id']),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(routes: [GoRoute(path: '/employer/talent-pool', builder: (_, __) => const TalentPoolPage())]),
            StatefulShellBranch(routes: [GoRoute(path: '/employer/profile', builder: (_, __) => const ProfilePage())]),
          ],
        ),
        // Backward-compatible direct path in case of old deep links.
        GoRoute(
          path: '/employer/post-job',
          redirect: (_, __) => employerPostJob,
        ),
        GoRoute(
          path: '/employer/candidates/:jobId',
          builder: (_, state) => TalentPipelineScreen(jobId: state.pathParameters['jobId']!),
        ),
        GoRoute(
          path: '/employer/candidate/:applicationId',
          builder: (_, state) => CandidateProfileScreen(applicationId: state.pathParameters['applicationId']!),
        ),
        GoRoute(
          path: '/employer/candidate/view/:userId',
          builder: (_, state) => CandidateProfileByUserIdScreen(userId: state.pathParameters['userId']!),
        ),
        GoRoute(
          path: '/employer/candidate-portfolio/:userId',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CandidateFullPortfolioScreen(
              userId: state.pathParameters['userId']!,
              displayName: extra?['displayName'] as String?,
              email: extra?['email'] as String?,
              summary: extra?['summary'] as String?,
            );
          },
        ),
        GoRoute(path: assessmentList, builder: (_, __) => const AssessmentListScreen()),
        GoRoute(
          path: '/assessment/quiz/:categoryId',
          builder: (_, state) => AssessmentQuizScreen(categoryId: state.pathParameters['categoryId']!),
        ),
        GoRoute(
          path: assessmentResult,
          builder: (_, state) => AssessmentResultScreen(result: state.extra as models.AssessmentResult?),
        ),
        GoRoute(path: community, builder: (_, __) => const CommunityScreen()),
        GoRoute(
          path: communityChallenge,
          builder: (_, __) => const PeerChallengeScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ScaffoldWithNavBar(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: dashboard, builder: (_, __) => const StudentDashboardScreen())]),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: skills,
                  builder: (_, __) => const SkillsPage(),
                  routes: [
                    GoRoute(path: 'categories', builder: (_, __) => const SkillsCategoriesPage()),
                    GoRoute(
                      path: 'assess/:categoryId',
                      builder: (_, state) => SkillAssessPage(categoryId: state.pathParameters['categoryId']),
                    ),
                    GoRoute(
                      path: 'results/:categoryId',
                      builder: (_, state) => SkillResultsPage(categoryId: state.pathParameters['categoryId']),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(routes: [GoRoute(path: portfolio, builder: (_, __) => const PortfolioScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: profile, builder: (_, __) => const ProfilePage())]),
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }
}

class _NoOpListenable extends ChangeNotifier {}
