import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

/// S-016: Application Tracker. Application History + Status per FR-015.
class ApplicationTrackerPage extends StatelessWidget {
  const ApplicationTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Application History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go(router.AppRouter.jobBoard),
        ),
      ),
      body: EmptyState(
        icon: Icons.history_rounded,
        iconColor: AppColors.primary,
        headline: 'No applications yet',
        body: 'Application status (Pending / Viewed / Accepted / Rejected) will appear here.',
        actionLabel: 'Browse jobs',
        onAction: () => context.go(router.AppRouter.jobBoard),
      ),
    );
  }
}
