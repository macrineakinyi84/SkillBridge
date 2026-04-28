import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

class CandidateFullPortfolioScreen extends StatelessWidget {
  const CandidateFullPortfolioScreen({
    super.key,
    required this.userId,
    this.displayName,
    this.email,
    this.summary,
  });

  final String userId;
  final String? displayName;
  final String? email;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = displayName ?? 'Candidate';
    final data = _demoPortfolioFor(userId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Full portfolio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _SectionCard(
            title: name,
            subtitle: email ?? 'No email provided',
            body: summary ?? 'Portfolio overview',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.m),
          _ListSection(title: 'Experience', items: data.experience, isDark: isDark),
          const SizedBox(height: AppSpacing.m),
          _ListSection(title: 'Education', items: data.education, isDark: isDark),
          const SizedBox(height: AppSpacing.m),
          _ListSection(title: 'Projects', items: data.projects, isDark: isDark),
          const SizedBox(height: AppSpacing.m),
          _ListSection(title: 'Certifications', items: data.certs, isDark: isDark),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.body, required this.isDark});
  final String title;
  final String subtitle;
  final String body;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.title, required this.items, required this.isDark});
  final String title;
  final List<String> items;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.s),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PortfolioBundle {
  const _PortfolioBundle({required this.experience, required this.education, required this.projects, required this.certs});
  final List<String> experience;
  final List<String> education;
  final List<String> projects;
  final List<String> certs;
}

_PortfolioBundle _demoPortfolioFor(String userId) {
  // Deterministic demo content per user id.
  final key = userId.isEmpty ? 0 : userId.codeUnits.fold<int>(0, (a, b) => a + b) % 3;
  if (key == 1) {
    return const _PortfolioBundle(
      experience: ['Flutter Intern at Mtaa Digital (2025-2026)', 'Volunteer IT Support at County ICT Office'],
      education: ['BSc Computer Science - JKUAT (2022-2026)'],
      projects: ['SkillBridge mobile app', 'Campus Events Finder'],
      certs: ['Flutter & Dart (Udemy)', 'REST APIs (Postman)'],
    );
  }
  if (key == 2) {
    return const _PortfolioBundle(
      experience: ['Frontend Freelancer (2024-2026)', 'Peer coding mentor'],
      education: ['BSc Information Technology - UoN'],
      projects: ['SME Inventory System', 'Job Board UI Kit'],
      certs: ['Git & GitHub', 'UI/UX Foundations'],
    );
  }
  return const _PortfolioBundle(
    experience: ['Software Trainee at Pwani Works', 'Tech community facilitator'],
    education: ['BSc Software Engineering - Strathmore'],
    projects: ['Learning Tracker', 'Portfolio PDF Export'],
    certs: ['Agile Foundations', 'Cloud Fundamentals'],
  );
}

