import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';

/// Certificate of completion for a learning path. Share/Download as PDF.
class LearningPathCertificateScreen extends StatelessWidget {
  const LearningPathCertificateScreen({
    super.key,
    required this.pathId,
    required this.pathTitle,
  });

  final String pathId;
  final String pathTitle;

  Future<pw.Document> _buildPdf(BuildContext context) async {
    final pdf = pw.Document();
    final date = DateTime.now();
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final userName = AuthScope.maybeOf(context)?.state.user?.displayName ?? 'Learner';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(48),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.purple300, width: 3),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'Certificate of Completion',
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'This is to certify that',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    userName,
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'has successfully completed the learning path',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    pathTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'Date: $dateStr',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'SkillBridge • skillupkenya.com',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _shareOrDownload(BuildContext context) async {
    final pdf = await _buildPdf(context);
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'skillbridge-certificate-$pathId.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    final userName = AuthScope.maybeOf(context)?.state.user?.displayName ?? 'Learner';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Certificate'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _shareOrDownload(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareOrDownload(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: AppRadius.radiusL,
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Certificate of Completion',
                    style: AppTypography.h1(context, isDark: isDark).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text('This is to certify that', style: AppTypography.body(context, isDark: isDark)),
                  const SizedBox(height: AppSpacing.s),
                  Text(userName, style: AppTypography.h2(context, isDark: isDark)),
                  const SizedBox(height: AppSpacing.m),
                  Text('has successfully completed the learning path', style: AppTypography.body(context, isDark: isDark)),
                  const SizedBox(height: AppSpacing.s),
                  Text(pathTitle, style: AppTypography.h2(context, isDark: isDark), textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.l),
                  Text('Date: $dateStr', style: AppTypography.caption(context, isDark: isDark)),
                  const SizedBox(height: AppSpacing.m),
                  Text('SkillBridge • skillupkenya.com', style: AppTypography.caption(context, isDark: isDark)),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: () => _shareOrDownload(context),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Download / Share PDF'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
