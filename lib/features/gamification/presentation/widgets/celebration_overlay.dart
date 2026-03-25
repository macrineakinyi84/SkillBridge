import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

/// Full-screen celebration overlay. Types: confetti, trophy, levelUp, badge.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.xpAwarded,
    this.badgeImageUrl,
    this.lottiePath,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 3),
  });

  final CelebrationType type;
  final String? title;
  final String? subtitle;
  final int? xpAwarded;
  final String? badgeImageUrl;
  final String? lottiePath;
  final VoidCallback? onDismiss;
  final Duration autoDismissDuration;

  static const String confetti = 'confetti';
  static const String trophy = 'trophy';
  static const String levelUp = 'levelUp';
  static const String badge = 'badge';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (lottiePath != null && lottiePath!.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: Lottie.asset(lottiePath!, fit: BoxFit.contain),
                )
              else
                Icon(
                  _iconForType(type),
                  size: 120,
                  color: AppColors.xpGold,
                ),
              const SizedBox(height: AppSpacing.l),
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (xpAwarded != null && xpAwarded! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$xpAwarded XP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.xpGold,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
              if (badgeImageUrl != null && badgeImageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(badgeImageUrl!, width: 80, height: 80, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Tap to dismiss',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForType(CelebrationType t) {
    switch (t) {
      case CelebrationType.confetti:
        return Icons.celebration_rounded;
      case CelebrationType.trophy:
        return Icons.emoji_events_rounded;
      case CelebrationType.levelUp:
        return Icons.trending_up_rounded;
      case CelebrationType.badge:
        return Icons.military_tech_rounded;
    }
  }
}

enum CelebrationType { confetti, trophy, levelUp, badge }
