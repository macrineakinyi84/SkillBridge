import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../domain/models/challenge.dart';
import '../../domain/repositories/community_repository.dart';

/// Peer challenges: share link (WhatsApp), incoming (accept), active (countdown), completed (Win/Loss/Draw + XP).
class PeerChallengeScreen extends StatefulWidget {
  const PeerChallengeScreen({super.key});

  @override
  State<PeerChallengeScreen> createState() => _PeerChallengeScreenState();
}

class _PeerChallengeScreenState extends State<PeerChallengeScreen> {
  final CommunityRepository _repo = sl<CommunityRepository>();

  List<Challenge> _challenges = [];
  bool _loading = false;
  String _shareCategory = 'Digital Literacy';
  static const String _appLink = 'https://skillupkenya.app/challenge';

  String get _userId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId.isEmpty) return;
    setState(() => _loading = true);
    try {
      final list = await _repo.getChallengesForUser(userId);
      if (mounted) setState(() { _challenges = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shareChallenge() async {
    final message =
        'I challenge you to beat my $_shareCategory score on SkillUp Kenya! $_appLink';
    try {
      await Share.share(
        message,
        subject: 'SkillUp Kenya Challenge',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Future<void> _openWhatsAppShare() async {
    final text = Uri.encodeComponent(
      'I challenge you to beat my $_shareCategory score on SkillUp Kenya! $_appLink',
    );
    final url = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await _shareChallenge();
    }
  }

  Future<void> _acceptChallenge(Challenge c) async {
    final ok = await _repo.acceptChallenge(c.id, _userId);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge accepted!')));
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not accept challenge')));
      }
    }
  }

  List<Challenge> get _incoming =>
      _challenges.where((c) => c.status == ChallengeStatus.pending && c.toUserId == _userId).toList();
  List<Challenge> get _active =>
      _challenges.where((c) => c.status == ChallengeStatus.active).toList();
  List<Challenge> get _completed =>
      _challenges.where((c) => c.status == ChallengeStatus.completed).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Peer Challenge', style: AppTypography.h1(context, isDark: isDark)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ShareCard(
                      category: _shareCategory,
                      onShare: _shareChallenge,
                      onWhatsApp: _openWhatsAppShare,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    if (_incoming.isNotEmpty) ...[
                      Text('Incoming challenges', style: AppTypography.h2(context, isDark: isDark)),
                      const SizedBox(height: AppSpacing.s),
                      ..._incoming.map((c) => _ChallengeCard(
                            challenge: c,
                            isDark: isDark,
                            onAccept: () => _acceptChallenge(c),
                            currentUserId: _userId,
                          )),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    if (_active.isNotEmpty) ...[
                      Text('Active', style: AppTypography.h2(context, isDark: isDark)),
                      const SizedBox(height: AppSpacing.s),
                      ..._active.map((c) => _ActiveChallengeCard(challenge: c, isDark: isDark, currentUserId: _userId)),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    if (_completed.isNotEmpty) ...[
                      Text('Completed', style: AppTypography.h2(context, isDark: isDark)),
                      const SizedBox(height: AppSpacing.s),
                      ..._completed.map((c) => _CompletedChallengeCard(challenge: c, isDark: isDark, currentUserId: _userId)),
                    ],
                    if (_incoming.isEmpty && _active.isEmpty && _completed.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          'No challenges yet. Share the link to challenge a friend!',
                          style: AppTypography.bodySecondary(context, isDark: isDark),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.category,
    required this.onShare,
    required this.onWhatsApp,
    required this.isDark,
  });

  final String category;
  final VoidCallback onShare;
  final VoidCallback onWhatsApp;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Card(
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge a friend',
              style: AppTypography.h2(context, isDark: isDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Share a link so they can beat your $category score.',
              style: AppTypography.bodySecondary(context, isDark: isDark),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.isDark,
    required this.onAccept,
    required this.currentUserId,
  });

  final Challenge challenge;
  final bool isDark;
  final VoidCallback onAccept;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final fromName = challenge.fromDisplayName ?? 'Someone';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$fromName challenges you to ${challenge.categoryName}',
              style: AppTypography.body(context, isDark: isDark),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onAccept,
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChallengeCard extends StatelessWidget {
  const _ActiveChallengeCard({
    required this.challenge,
    required this.isDark,
    required this.currentUserId,
  });

  final Challenge challenge;
  final bool isDark;
  final String currentUserId;

  static String _countdown(DateTime expiresAt) {
    final d = expiresAt.difference(DateTime.now());
    if (d.isNegative) return 'Expired';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m}m left';
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _countdown(challenge.expiresAt),
                  style: AppTypography.body(context, isDark: isDark).copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${challenge.categoryName} · vs ${challenge.fromUserId == currentUserId ? challenge.toDisplayName ?? "Friend" : challenge.fromDisplayName ?? "Friend"}',
              style: AppTypography.bodySecondary(context, isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedChallengeCard extends StatelessWidget {
  const _CompletedChallengeCard({
    required this.challenge,
    required this.isDark,
    required this.currentUserId,
  });

  final Challenge challenge;
  final bool isDark;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final won = challenge.winnerUserId == currentUserId;
    final draw = challenge.winnerUserId == null || challenge.winnerUserId!.isEmpty;
    String result;
    Color resultColor;
    if (draw) {
      result = 'Draw';
      resultColor = AppColors.textSecondary;
    } else if (won) {
      result = 'Win';
      resultColor = AppColors.success;
    } else {
      result = 'Loss';
      resultColor = AppColors.error;
    }
    final xp = challenge.xpAwarded ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
        title: Text(
          challenge.categoryName,
          style: AppTypography.body(context, isDark: isDark),
        ),
        subtitle: Text(
          '+$xp XP',
          style: AppTypography.caption(context, isDark: isDark).copyWith(color: AppColors.xpGold),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: resultColor.withValues(alpha: 0.2),
            borderRadius: AppRadius.radiusM,
          ),
          child: Text(
            result,
            style: AppTypography.body(context, isDark: isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  color: resultColor,
                ),
          ),
        ),
      ),
    );
  }
}
