import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

enum PortfolioTheme {
  minimal,
  bold,
  professional,
  creative,
}

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({
    super.key,
    this.theme = PortfolioTheme.professional,
  });

  final PortfolioTheme theme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _themeColors(theme, isDark: isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.surface,
            title: const Text('Public Profile'),
          ),
          SliverToBoxAdapter(child: _buildHero(context, colors)),
          SliverToBoxAdapter(child: _buildSkillsRadar(context, colors)),
          SliverToBoxAdapter(child: _buildBadgesRow(context, colors)),
          SliverToBoxAdapter(child: _buildXpCard(context, colors)),
          SliverToBoxAdapter(child: _buildTimelineSection(context, colors, title: 'Experience')),
          SliverToBoxAdapter(child: _buildTimelineSection(context, colors, title: 'Education')),
          SliverToBoxAdapter(child: _buildProjectsSection(context, colors)),
          SliverToBoxAdapter(child: _buildCertificationsSection(context, colors)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Share.share(
                      'Check out my SkillUp Kenya profile: https://skillupkenya.com/u/profile',
                      subject: 'My SkillBridge profile',
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Connect on SkillUp'),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  _PortfolioThemeColors _themeColors(PortfolioTheme theme, {required bool isDark}) {
    switch (theme) {
      case PortfolioTheme.minimal:
        return _PortfolioThemeColors(
          background: isDark ? AppColors.backgroundDark : Colors.white,
          surface: isDark ? AppColors.surfaceDark : Colors.white,
          accent: AppColors.textPrimary,
        );
      case PortfolioTheme.bold:
        return _PortfolioThemeColors(
          background: AppColors.primary,
          surface: Colors.white,
          accent: AppColors.error,
        );
      case PortfolioTheme.creative:
        return _PortfolioThemeColors(
          background: AppColors.gradientWarmStart,
          surface: Colors.white,
          accent: AppColors.secondary,
        );
      case PortfolioTheme.professional:
      default:
        return _PortfolioThemeColors(
          background: isDark ? AppColors.backgroundDark : AppColors.background,
          surface: isDark ? AppColors.surfaceDark : AppColors.surface,
          accent: AppColors.primary,
        );
    }
  }

  Widget _buildHero(BuildContext context, _PortfolioThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xl, AppSpacing.l, AppSpacing.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colors.accent.withOpacity(0.15),
            child: Icon(Icons.person_rounded, size: 40, color: colors.accent),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Your Name', style: AppTypography.h1(context, isDark: isDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.accent.withOpacity(0.15),
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        'Level 3 • Rising Star',
                        style: AppTypography.caption(context, isDark: isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Aspiring Mobile Developer',
                  style: AppTypography.bodySecondary(context, isDark: isDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nairobi County • Open to internships',
                  style: AppTypography.caption(context, isDark: isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsRadar(BuildContext context, _PortfolioThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skills = [
      {'label': 'Digital Literacy', 'value': 78.0},
      {'label': 'Communication', 'value': 65.0},
      {'label': 'Technical', 'value': 72.0},
      {'label': 'Business', 'value': 60.0},
      {'label': 'Leadership', 'value': 70.0},
    ];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skills snapshot', style: AppTypography.h2(context, isDark: isDark)),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      RadarDataSet(
                        fillColor: colors.accent.withOpacity(0.2),
                        borderColor: colors.accent,
                        entryRadius: 3,
                        dataEntries: skills
                            .map((s) => RadarEntry(value: (s['value'] as double) / 100 * 5))
                            .toList(),
                      ),
                    ],
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(color: Color(0xFFE5E7EB)),
                    tickBorderData: const BorderSide(color: Color(0xFFE5E7EB)),
                    gridBorderData: const BorderSide(color: Color(0xFFE5E7EB)),
                    titleTextStyle: AppTypography.caption(context, isDark: isDark),
                    titlePositionPercentageOffset: 0.2,
                    getTitle: (index, angle) => RadarChartTitle(text: skills[index]['label'] as String),
                    tickCount: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow(BuildContext context, _PortfolioThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badges = [
      {'label': 'First Step', 'description': 'Completed onboarding'},
      {'label': 'Assessment Hero', 'description': 'Completed first assessment'},
      {'label': 'On Fire', 'description': '7-day learning streak'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: badges.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
          itemBuilder: (context, index) {
            final badge = badges[index];
            return GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(badge['label'] as String),
                    content: Text(badge['description'] as String),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                    ],
                  ),
                );
              },
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.radiusL,
                ),
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 20, color: colors.accent),
                    const SizedBox(height: 4),
                    Text(
                      badge['label'] as String,
                      style: AppTypography.caption(context, isDark: isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildXpCard(BuildContext context, _PortfolioThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.radiusL,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.xpGold),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level 3 • Rising Star', style: AppTypography.body(context, isDark: isDark)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: AppRadius.radiusFull,
                      child: LinearProgressIndicator(
                        value: 0.45,
                        minHeight: 6,
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.background,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('450 / 1000 XP to next level', style: AppTypography.caption(context, isDark: isDark)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, _PortfolioThemeColors colors, {required String title}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      {'title': '$title Item 1', 'subtitle': 'Organisation • 2023 - Present'},
      {'title': '$title Item 2', 'subtitle': 'Organisation • 2021 - 2023'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: colors.accent.withOpacity(0.4),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String, style: AppTypography.body(context, isDark: isDark)),
                        const SizedBox(height: 2),
                        Text(item['subtitle'] as String, style: AppTypography.caption(context, isDark: isDark)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context, _PortfolioThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = [
      {'title': 'Job Search App', 'subtitle': 'Flutter • Firebase', 'url': 'https://example.com'},
      {'title': 'E-commerce Website', 'subtitle': 'React • Node', 'url': 'https://example.com'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Featured projects', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          ...projects.map(
            (p) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.radiusL,
              ),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.radiusL,
                  ),
                  child: Icon(Icons.image_rounded, color: colors.accent),
                ),
                title: Text(p['title'] as String, style: AppTypography.body(context, isDark: isDark)),
                subtitle: Text(p['subtitle'] as String, style: AppTypography.caption(context, isDark: isDark)),
                trailing: const Icon(Icons.open_in_new_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection(BuildContext context, _PortfolioThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final certs = [
      {'title': 'Google Digital Skills', 'subtitle': 'Google • 2023'},
      {'title': 'Cisco Networking Basics', 'subtitle': 'Cisco • 2022'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Certifications', style: AppTypography.h2(context, isDark: isDark)),
          const SizedBox(height: 8),
          ...certs.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.radiusL,
              ),
              child: ListTile(
                leading: Icon(Icons.card_membership_rounded, color: colors.accent),
                title: Text(c['title'] as String, style: AppTypography.body(context, isDark: isDark)),
                subtitle: Text(c['subtitle'] as String, style: AppTypography.caption(context, isDark: isDark)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioThemeColors {
  _PortfolioThemeColors({
    required this.background,
    required this.surface,
    required this.accent,
  });

  final Color background;
  final Color surface;
  final Color accent;
}

