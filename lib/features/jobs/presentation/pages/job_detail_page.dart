import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../core/router/app_router.dart' as router;

/// Job Details & Apply Now (S-015). Apply flow with cover note per MVP FR-014.
class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, this.jobId});

  final String? jobId;

  Future<void> _applyWithCoverNote(BuildContext context) async {
    final coverController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply with cover note'),
        content: TextField(
          controller: coverController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Introduce yourself and why you\'re a good fit...',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit application'),
          ),
        ],
      ),
    );
    if (context.mounted && submitted == true) {
      // TODO: call backend POST /api/jobs/apply when endpoint exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(coverController.text.trim().isEmpty
              ? 'Application submitted.'
              : 'Application submitted with your cover note.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Job details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job title placeholder', style: AppTypography.h1(context, isDark: isDark)),
            const SizedBox(height: 8),
            Text('Company • Location • Type', style: AppTypography.caption(context, isDark: isDark)),
            const SizedBox(height: 16),
            Text('Description and required skills will appear here. Match score displayed per PDR (green >70%, yellow 40–69%, grey <40%).', style: AppTypography.body(context, isDark: isDark)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _applyWithCoverNote(context),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
