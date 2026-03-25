import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

/// Messages — In-app chat with employers (Phase 2 / S-027). Notifications link.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: EmptyState(
        icon: Icons.chat_rounded,
        iconColor: AppColors.primary,
        headline: 'Messages (Phase 2)',
        body: 'In-app chat with employers will be available in a future release. Check Notifications for updates.',
        actionLabel: 'Open Notifications',
        onAction: () => context.push(router.AppRouter.notifications),
      ),
    );
  }
}
