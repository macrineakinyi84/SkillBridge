import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/models/gamification_profile.dart';

/// Horizontal XP progress to next level. Level badge, XP amount, next level name.
class XpProgressBar extends StatefulWidget {
  const XpProgressBar({
    super.key,
    required this.profile,
    this.height = 12,
    this.animated = true,
    this.showLevelUpPulse = false,
  });

  final GamificationProfile profile;
  final double height;
  final bool animated;
  final bool showLevelUpPulse;

  @override
  State<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends State<XpProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    if (widget.showLevelUpPulse) _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.profile.xpToNextLevel + widget.profile.xpInCurrentLevel;
    final progress = total > 0
        ? (widget.profile.xpInCurrentLevel / widget.profile.xpToNextLevel)
            .clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.levelBadge.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv.${widget.profile.level} ${widget.profile.levelName}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.levelBadge,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.profile.xpInCurrentLevel} / ${widget.profile.xpToNextLevel} XP',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: widget.height,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
          ),
        ),
      ],
    );
  }
}
