import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

enum NudgeType {
  streakWarning,
  profileIncomplete,
  newMatches,
  learningReminder,
}

/// Dismissible banner at top of dashboard. Color by urgency; one at a time; auto-dismiss 8s; tap navigates.
class SmartNudgeBanner extends StatefulWidget {
  const SmartNudgeBanner({
    super.key,
    required this.nudgeType,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  final NudgeType nudgeType;
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  @override
  State<SmartNudgeBanner> createState() => _SmartNudgeBannerState();
}

class _SmartNudgeBannerState extends State<SmartNudgeBanner> {
  static const Duration autoDismissDuration = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    Future.delayed(autoDismissDuration, () {
      if (mounted && widget.onDismiss != null) widget.onDismiss!();
    });
  }

  static IconData _iconFor(NudgeType type) {
    switch (type) {
      case NudgeType.streakWarning:
        return Icons.local_fire_department_rounded;
      case NudgeType.profileIncomplete:
        return Icons.auto_awesome_rounded;
      case NudgeType.newMatches:
        return Icons.work_rounded;
      case NudgeType.learningReminder:
        return Icons.menu_book_rounded;
    }
  }

  static Color _colorFor(NudgeType type, bool isDark) {
    switch (type) {
      case NudgeType.streakWarning:
        return AppColors.streakFlame;
      case NudgeType.profileIncomplete:
        return AppColors.primary;
      case NudgeType.newMatches:
        return AppColors.success;
      case NudgeType.learningReminder:
        return AppColors.levelBadge;
    }
  }

  void _onTap() {
    switch (widget.nudgeType) {
      case NudgeType.streakWarning:
        context.push(router.AppRouter.jobBoard);
        break;
      case NudgeType.profileIncomplete:
        context.push(router.AppRouter.profile);
        break;
      case NudgeType.newMatches:
        context.push(router.AppRouter.jobBoard);
        break;
      case NudgeType.learningReminder:
        context.push(router.AppRouter.learningHub);
        break;
    }
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorFor(widget.nudgeType, isDark);

    return Dismissible(
      key: Key('nudge_${widget.nudgeType.name}'),
      direction: DismissDirection.up,
      onDismissed: (_) => widget.onDismiss?.call(),
      child: Material(
        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: AppRadius.radiusL,
        child: InkWell(
          onTap: _onTap,
          borderRadius: AppRadius.radiusL,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
            child: Row(
              children: [
                Icon(_iconFor(widget.nudgeType), color: color, size: 28),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.body(context, isDark: isDark).copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.message,
                        style: AppTypography.caption(context, isDark: isDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDismiss,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
