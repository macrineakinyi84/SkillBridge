import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/theme/app_colors.dart';

/// Full-screen scrollable preview of the generated PDF CV.
class CvPreviewScreen extends StatelessWidget {
  const CvPreviewScreen({super.key});

  Future<pw.Document> _buildPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Your Name', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Aspiring Software Developer'),
                pw.SizedBox(height: 16),
                pw.Text('Experience', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Your experience entries will appear here.'),
              ],
            ),
          );
        },
      ),
    );
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview CV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () async {
              final doc = await _buildPdf();
              final bytes = await doc.save();
              await Printing.sharePdf(bytes: bytes, filename: 'skillbridge-cv.pdf');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              // Simple share of a placeholder URL; in a real app this would be a real link.
              await Share.share('Check out my SkillBridge CV.');
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          final doc = await _buildPdf();
          return doc.save();
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'skillbridge-cv.pdf',
      ),
    );
  }
}

