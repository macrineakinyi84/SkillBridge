import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/auth_scope.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).state.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            onPressed: () => context.push(router.AppRouter.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 52, backgroundColor: AppColors.primary.withOpacity(0.2), child: Icon(Icons.person_rounded, size: 48, color: AppColors.primary)),
                const SizedBox(height: 16),
                Text(user?.displayName ?? 'No name', style: AppTypography.h1(context, isDark: isDark)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: AppTypography.caption(context, isDark: isDark)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Personal Info', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.badge_rounded, color: AppColors.primary), title: Text('Name', style: AppTypography.body(context, isDark: isDark)), subtitle: Text(user?.displayName ?? 'Not set', style: AppTypography.caption(context, isDark: isDark))),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.email_rounded, color: AppColors.primary), title: Text('Email', style: AppTypography.body(context, isDark: isDark)), subtitle: Text(user?.email ?? 'Not set', style: AppTypography.caption(context, isDark: isDark))),
          const SizedBox(height: 28),
          Text('Social Links', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.link_rounded, color: AppColors.primary), title: Text('LinkedIn', style: AppTypography.body(context, isDark: isDark)), subtitle: Text('Not connected', style: AppTypography.caption(context, isDark: isDark))),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.code_rounded, color: AppColors.primary), title: Text('GitHub', style: AppTypography.body(context, isDark: isDark)), subtitle: Text('Not connected', style: AppTypography.caption(context, isDark: isDark))),
          const SizedBox(height: 32),
          OutlinedButton.icon(onPressed: () => AuthScope.of(context).signOut(), icon: const Icon(Icons.logout_rounded, size: 20), label: const Text('Sign out'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
