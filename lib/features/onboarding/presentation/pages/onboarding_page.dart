import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../notifications/data/services/fcm_service.dart';

/// Value proposition slides + role selection (Student / Employer).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _numSlides = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _numSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _showRoleSelection(context);
    }
  }

  /// Step 5: Request notification permission after role selection, then navigate.
  Future<void> _onRoleSelected(BuildContext context, VoidCallback navigate) async {
    Navigator.of(context).pop();
    await FcmService.requestPermission();
    if (context.mounted) navigate();
  }

  void _showRoleSelection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'I am a',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.school_rounded, color: AppColors.primary),
                title: const Text('Student / Youth'),
                subtitle: const Text('Track skills, build portfolio, get job-ready'),
                onTap: () => _onRoleSelected(ctx, () => context.go(router.AppRouter.login)),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.business_rounded, color: AppColors.primary),
                title: const Text('Employer'),
                subtitle: const Text('Post jobs, find candidates'),
                onTap: () => _onRoleSelected(ctx, () => context.go('${router.AppRouter.login}?next=${router.AppRouter.employerDashboard}')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _Slide(icon: Icons.trending_up_rounded, title: 'Bridge your skills', body: 'Track what you know, spot gaps, and see your career readiness score.', isDark: isDark),
                  _Slide(icon: Icons.folder_special_rounded, title: 'Build your portfolio', body: 'Add projects, education, and certificates. Export your CV as PDF.', isDark: isDark),
                  _Slide(icon: Icons.work_rounded, title: 'Get job-ready', body: 'See job matches, take skill assessments, and get personalized recommendations.', isDark: isDark),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_numSlides, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == i ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.xxl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(_currentPage == _numSlides - 1 ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.icon, required this.title, required this.body, required this.isDark});
  final IconData icon;
  final String title;
  final String body;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
