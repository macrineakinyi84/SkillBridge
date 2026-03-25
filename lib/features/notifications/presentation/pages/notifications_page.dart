import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

/// Notifications Centre: Job matches, application updates, learning reminders, system alerts.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: EmptyState(
        icon: Icons.notifications_rounded,
        iconColor: AppColors.primary,
        headline: 'No notifications yet',
        body: 'Job matches, application updates, learning reminders, and system alerts will appear here.',
        actionLabel: 'Back to Home',
        onAction: () => context.go(router.AppRouter.dashboard),
      ),
    );
  }
}
