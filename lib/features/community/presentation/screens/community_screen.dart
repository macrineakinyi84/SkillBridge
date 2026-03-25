import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../employer/data/constants/kenyan_counties.dart';
import '../../domain/models/feed_item.dart';
import '../../domain/models/community_leaderboard_entry.dart';
import '../../domain/repositories/community_repository.dart';

/// Community: Feed and Leaderboard tabs; county selector; "Challenge a friend" FAB.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  final CommunityRepository _repo = sl<CommunityRepository>();
  late TabController _tabController;

  String _county = 'Nairobi';
  List<FeedItem> _feed = [];
  List<CommunityLeaderboardEntry> _leaderboard = [];
  CommunityLeaderboardEntry? _currentUserEntry;
  DateTime? _nextResetAt;
  bool _loadingFeed = false;
  bool _loadingLeaderboard = false;

  String get _userId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeed();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _loadingFeed = true);
    try {
      final list = await _repo.getFeed(_county, limit: 20);
      if (mounted) setState(() { _feed = list; _loadingFeed = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingFeed = false);
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loadingLeaderboard = true);
    try {
      final data = await _repo.getLeaderboard(_county, currentUserId: _userId.isEmpty ? null : _userId);
      if (mounted) {
        setState(() {
          _leaderboard = data.entries;
          _currentUserEntry = data.currentUserEntry;
          _nextResetAt = data.nextResetAt;
          _loadingLeaderboard = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLeaderboard = false);
    }
  }

  void _onCountyChanged(String? value) {
    if (value == null) return;
    setState(() => _county = value);
    _loadFeed();
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Community', style: AppTypography.h1(context, isDark: isDark)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.bottomPaddingWithFab),
        child: TabBarView(
          controller: _tabController,
          children: [
            _FeedTab(
            county: _county,
            counties: kenyanCounties,
            onCountyChanged: _onCountyChanged,
            feed: _feed,
            loading: _loadingFeed,
            onRefresh: _loadFeed,
            isDark: isDark,
          ),
            _LeaderboardTab(
              county: _county,
              nextResetAt: _nextResetAt,
              entries: _leaderboard,
              currentUserEntry: _currentUserEntry,
              loading: _loadingLeaderboard,
              onRefresh: _loadLeaderboard,
              isDark: isDark,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(router.AppRouter.communityChallenge),
        icon: const Icon(Icons.emoji_events_outlined),
        label: const Text('Challenge a friend'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.county,
    required this.counties,
    required this.onCountyChanged,
    required this.feed,
    required this.loading,
    required this.onRefresh,
    required this.isDark,
  });

  final String county;
  final List<String> counties;
  final void Function(String?) onCountyChanged;
  final List<FeedItem> feed;
  final bool loading;
  final VoidCallback onRefresh;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, 0),
              child: DropdownButtonFormField<String>(
                value: county,
                decoration: InputDecoration(
                  labelText: 'County',
                  border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                ),
                items: counties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: onCountyChanged,
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (feed.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No activity in $county yet.',
                  style: AppTypography.bodySecondary(context, isDark: isDark),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.l),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = feed[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: _FeedItemTile(item: item, isDark: isDark),
                    );
                  },
                  childCount: feed.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeedItemTile extends StatelessWidget {
  const _FeedItemTile({required this.item, required this.isDark});

  final FeedItem item;
  final bool isDark;

  static String _timeAgo(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static IconData _iconFor(FeedActivityType type) {
    switch (type) {
      case FeedActivityType.assessment:
        return Icons.quiz_outlined;
      case FeedActivityType.job:
        return Icons.work_outline;
      case FeedActivityType.badge:
        return Icons.emoji_events_outlined;
      case FeedActivityType.level:
        return Icons.trending_up;
    }
  }

  static String _emojiFor(FeedActivityType type) {
    switch (type) {
      case FeedActivityType.assessment:
        return '🎓';
      case FeedActivityType.job:
        return '💼';
      case FeedActivityType.badge:
        return '🏆';
      case FeedActivityType.level:
        return '⬆️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            (item.displayName.isNotEmpty ? item.displayName[0] : '?').toUpperCase(),
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        title: Row(
          children: [
            Text(_emojiFor(item.type), style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.message,
                style: AppTypography.body(context, isDark: isDark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${item.displayName} · ${_timeAgo(item.createdAt)}',
            style: AppTypography.caption(context, isDark: isDark),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({
    required this.county,
    required this.nextResetAt,
    required this.entries,
    required this.currentUserEntry,
    required this.loading,
    required this.onRefresh,
    required this.isDark,
  });

  final String county;
  final DateTime? nextResetAt;
  final List<CommunityLeaderboardEntry> entries;
  final CommunityLeaderboardEntry? currentUserEntry;
  final bool loading;
  final VoidCallback onRefresh;
  final bool isDark;

  static String _countdown(DateTime? next) {
    if (next == null) return '';
    final d = next.difference(DateTime.now());
    if (d.isNegative) return 'Resets soon';
    final days = d.inDays;
    final hours = d.inHours % 24;
    if (days > 0) return 'Resets in ${days}d ${hours}h';
    return 'Resets in ${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This week in $county',
                    style: AppTypography.h1(context, isDark: isDark),
                  ),
                  if (nextResetAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _countdown(nextResetAt),
                      style: AppTypography.caption(context, isDark: isDark),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final e = entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: _LeaderboardRow(
                        entry: e,
                        isDark: isDark,
                        isTopThree: e.rank <= 3,
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
              ),
            ),
            if (currentUserEntry != null &&
                (entries.isEmpty || !entries.any((e) => e.userId == currentUserEntry!.userId))) ...[
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Text(
                    'Your position',
                    style: AppTypography.caption(context, isDark: isDark),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: _LeaderboardRow(
                    entry: currentUserEntry!,
                    isDark: isDark,
                    isTopThree: false,
                    isPinned: true,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isDark,
    this.isTopThree = false,
    this.isPinned = false,
  });

  final CommunityLeaderboardEntry entry;
  final bool isDark;
  final bool isTopThree;
  final bool isPinned;

  static Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD4AF37);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final medalColor = isTopThree ? _medalColor(entry.rank) : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: isPinned ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08)) : surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
        leading: SizedBox(
          width: 36,
          child: isTopThree
              ? Text(
                  '#${entry.rank}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: medalColor, fontSize: 16),
                )
              : Text(
                  '${entry.rank}',
                  style: AppTypography.body(context, isDark: isDark),
                ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                (entry.displayName?.isNotEmpty == true ? entry.displayName![0] : '?').toUpperCase(),
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.displayName ?? 'User',
                    style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'L${entry.level} · ${entry.levelName}',
                    style: AppTypography.caption(context, isDark: isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          '${entry.weeklyXp} XP',
          style: AppTypography.body(context, isDark: isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.xpGold,
              ),
        ),
      ),
    );
  }
}
