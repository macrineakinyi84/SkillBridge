import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// S-013: CV Preview & Export. Real-time preview before PDF (PDR 4.3).
class CvPreviewPage extends StatelessWidget {
  const CvPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Preview CV'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 20), label: const Text('Export PDF'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CV preview will show your portfolio data. Export as PDF when ready.', style: AppTypography.body(context, isDark: isDark)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Experience', style: AppTypography.h2(context, isDark: isDark)),
                  Text('Education', style: AppTypography.h2(context, isDark: isDark)),
                  Text('Projects', style: AppTypography.h2(context, isDark: isDark)),
                  Text('Certifications', style: AppTypography.h2(context, isDark: isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
