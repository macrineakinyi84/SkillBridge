import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

/// Notification center: grouped Today | This Week | Earlier; swipe to dismiss; tap to navigate; mark all read.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final NotificationRepository _repo = sl<NotificationRepository>();

  List<NotificationItem> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = false; _error = null; _loading = true; });
    try {
      final list = await _repo.getNotifications();
      if (mounted) setState(() { _notifications = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markAllRead() async {
    await _repo.markAllAsRead();
    if (mounted) _load();
  }

  Future<void> _dismiss(NotificationItem item) async {
    await _repo.dismiss(item.id);
    if (mounted) _load();
  }

  void _onTap(NotificationItem item) {
    if (item.isUnread) _repo.markAsRead(item.id);
    final jobId = item.data['jobId'];
    if (jobId != null && (item.type == NotificationType.jobMatch || item.type == NotificationType.applicationStatus)) {
      context.push(router.AppRouter.jobBoard + '/job/$jobId');
      return;
    }
    if (item.type == NotificationType.badgeEarned || item.type == NotificationType.levelUp) {
      context.push(router.AppRouter.profile);
      return;
    }
    if (item.type == NotificationType.microLesson || item.type == NotificationType.learningReminder) {
      context.push(router.AppRouter.learningHub);
      return;
    }
  }

  static ({String section, int index}) _sectionFor(DateTime at) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
    if (at.isAfter(startOfToday)) return (section: 'Today', index: 0);
    if (at.isAfter(startOfWeek)) return (section: 'This Week', index: 1);
    return (section: 'Earlier', index: 2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.h1(context, isDark: isDark)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_notifications.any((n) => n.isUnread))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorSection(message: _error!, onRetry: _load, isDark: isDark)
              : _notifications.isEmpty
                  ? EmptyStateWidget(
                      title: "You're all caught up! ✨",
                      subtitle: 'New updates will show here.',
                      icon: Icons.notifications_none_rounded,
                    )
                    : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.xxl),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final prev = index > 0 ? _notifications[index - 1] : null;
                          final showSection = prev == null ||
                              _sectionFor(prev.createdAt).index != _sectionFor(item.createdAt).index;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showSection)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.xs),
                                  child: Text(
                                    _sectionFor(item.createdAt).section,
                                    style: AppTypography.caption(context, isDark: isDark).copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ),
                              Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _dismiss(item),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: AppSpacing.m),
                                  color: AppColors.error.withValues(alpha: 0.2),
                                  child: const Icon(Icons.delete_outline, color: AppColors.error),
                                ),
                                child: _NotificationTile(
                                  item: item,
                                  isDark: isDark,
                                  onTap: () => _onTap(item),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}

String _timeAgo(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.isDark, required this.onTap});

  final NotificationItem item;
  final bool isDark;
  final VoidCallback onTap;

  static IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.jobMatch:
      case NotificationType.applicationStatus:
        return Icons.work_outline;
      case NotificationType.badgeEarned:
      case NotificationType.levelUp:
        return Icons.emoji_events_outlined;
      case NotificationType.streakWarning:
        return Icons.local_fire_department_outlined;
      case NotificationType.microLesson:
      case NotificationType.learningReminder:
        return Icons.menu_book_outlined;
      case NotificationType.weeklySummary:
      case NotificationType.jobsDigest:
        return Icons.summarize_outlined;
      case NotificationType.reengagement:
      case NotificationType.profileIncomplete:
      case NotificationType.generic:
        return Icons.notifications_outlined;
    }
  }

  static Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.jobMatch:
      case NotificationType.applicationStatus:
        return AppColors.success;
      case NotificationType.badgeEarned:
      case NotificationType.levelUp:
        return AppColors.xpGold;
      case NotificationType.streakWarning:
        return AppColors.streakFlame;
      case NotificationType.microLesson:
      case NotificationType.learningReminder:
        return AppColors.levelBadge;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final color = _colorFor(item.type);

    return Material(
      color: surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusM,
                ),
                child: Icon(_iconFor(item.type), color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.body(context, isDark: isDark).copyWith(
                            fontWeight: item.isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: AppTypography.caption(context, isDark: isDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(item.createdAt),
                      style: AppTypography.caption(context, isDark: isDark).copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              if (item.isUnread)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, required this.onRetry, required this.isDark});

  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error.withValues(alpha: 0.8)),
            const SizedBox(height: AppSpacing.l),
            Text(message, style: AppTypography.body(context, isDark: isDark), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
