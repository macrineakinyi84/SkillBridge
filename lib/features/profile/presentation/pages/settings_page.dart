import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/auth_scope.dart';

/// Settings (S-019). Nav tree: Account Settings | Notifications | Privacy | Help & FAQ | Logout.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Account Settings', style: AppTypography.h2(context, isDark: isDark)),
          ListTile(
            title: Text('Account info', style: AppTypography.body(context, isDark: isDark)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            title: Text('Change password', style: AppTypography.body(context, isDark: isDark)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(router.AppRouter.forgotPassword),
          ),
          const SizedBox(height: 24),
          Text('Notifications', style: AppTypography.h2(context, isDark: isDark)),
          ListTile(
            title: Text('Notification preferences', style: AppTypography.body(context, isDark: isDark)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(router.AppRouter.notifications),
          ),
          const SizedBox(height: 24),
          Text('Privacy', style: AppTypography.h2(context, isDark: isDark)),
          SwitchListTile(
            title: Text('Profile visible to employers', style: AppTypography.body(context, isDark: isDark)),
            value: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          Text('Support', style: AppTypography.h2(context, isDark: isDark)),
          ListTile(
            title: Text('Help & FAQ', style: AppTypography.body(context, isDark: isDark)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => AuthScope.of(context).signOut(),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}
