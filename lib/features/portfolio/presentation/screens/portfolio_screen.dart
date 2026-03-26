import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../student_data/data/repositories/student_portfolio_repository.dart';
import '../../../student_data/domain/models/portfolio_models.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// Rich portfolio builder with tabs for experience, education, projects, and certifications.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final StudentPortfolioRepository _repo = sl<StudentPortfolioRepository>();

  final List<_ExperienceEntry> _experience = [];
  final List<_EducationEntry> _education = [];
  final List<_ProjectEntry> _projects = [];
  final List<_CertificationEntry> _certs = [];

  double _completeness = 0.73;
  String _name = 'Your Name';
  String _headline = 'Aspiring Software Developer';
  ImageProvider? _photo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFromRepo();
  }

  void _loadFromRepo() {
    final profile = _repo.getProfile();
    if (profile != null) {
      _name = profile.displayName;
      _headline = profile.headline;
    }
    _experience
      ..clear()
      ..addAll(_repo.listExperience().map((e) => _ExperienceEntry(role: e.role, company: e.company, period: e.period, summary: e.summary)));
    _education
      ..clear()
      ..addAll(_repo.listEducation().map((e) => _EducationEntry(degree: e.degree, institution: e.institution, period: e.period, summary: e.summary)));
    _projects
      ..clear()
      ..addAll(_repo.listProjects().map((p) => _ProjectEntry(title: p.title, description: p.description, url: p.url, screenshotPath: p.screenshotPath)));
    _certs
      ..clear()
      ..addAll(_repo.listCertifications().map((c) => _CertificationEntry(name: c.name, issuer: c.issuer, date: c.date)));

    final total = _experience.length + _education.length + _projects.length + _certs.length;
    _completeness = total <= 0 ? 0.35 : (0.55 + (total / 20.0) * 0.45).clamp(0.35, 0.95);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context, isDark),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: AppRadius.radiusFull,
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              indicator: BoxDecoration(
                borderRadius: AppRadius.radiusFull,
                color: AppColors.primary,
              ),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Experience'),
                Tab(text: 'Education'),
                Tab(text: 'Projects'),
                Tab(text: 'Certifications'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListTab<_ExperienceEntry>(
                  context,
                  isDark: isDark,
                  items: _experience,
                  emptyTitle: 'Add your first role',
                  emptySubtitle: 'Show employers where you have worked and what you did.',
                  onAdd: () => _openExperienceSheet(),
                  itemBuilder: (item) => _PortfolioListTile(
                    title: item.role,
                    subtitle: '${item.company} • ${item.period}',
                    description: item.summary,
                  ),
                  onEditAt: (index) => _openExperienceSheet(existing: _experience[index], index: index),
                  onDeleteAt: (index) async {
                    final id = _repo.listExperience().elementAt(index).id;
                    await _repo.deleteExperience(id);
                    if (!mounted) return;
                    setState(_loadFromRepo);
                  },
                ),
                _buildListTab<_EducationEntry>(
                  context,
                  isDark: isDark,
                  items: _education,
                  emptyTitle: 'Add your education',
                  emptySubtitle: 'Diplomas, degrees and other formal training.',
                  onAdd: () => _openEducationSheet(),
                  itemBuilder: (item) => _PortfolioListTile(
                    title: item.degree,
                    subtitle: '${item.institution} • ${item.period}',
                    description: item.summary,
                  ),
                  onEditAt: (index) => _openEducationSheet(existing: _education[index], index: index),
                  onDeleteAt: (index) async {
                    final id = _repo.listEducation().elementAt(index).id;
                    await _repo.deleteEducation(id);
                    if (!mounted) return;
                    setState(_loadFromRepo);
                  },
                ),
                _buildListTab<_ProjectEntry>(
                  context,
                  isDark: isDark,
                  items: _projects,
                  emptyTitle: 'Showcase your projects',
                  emptySubtitle: 'Class work, freelance and personal projects.',
                  onAdd: () => _openProjectSheet(),
                  itemBuilder: (item) => _PortfolioListTile(
                    title: item.title,
                    subtitle: item.url ?? '',
                    description: item.description,
                  ),
                  onEditAt: (index) => _openProjectSheet(existing: _projects[index], index: index),
                  onDeleteAt: (index) async {
                    final id = _repo.listProjects().elementAt(index).id;
                    await _repo.deleteProject(id);
                    if (!mounted) return;
                    setState(_loadFromRepo);
                  },
                ),
                _buildListTab<_CertificationEntry>(
                  context,
                  isDark: isDark,
                  items: _certs,
                  emptyTitle: 'Add certifications',
                  emptySubtitle: 'Online courses and professional certificates.',
                  onAdd: () => _openCertificationSheet(),
                  itemBuilder: (item) => _PortfolioListTile(
                    title: item.name,
                    subtitle: item.issuer ?? '',
                    description: item.date,
                  ),
                  onEditAt: (index) => _openCertificationSheet(existing: _certs[index], index: index),
                  onDeleteAt: (index) async {
                    final id = _repo.listCertifications().elementAt(index).id;
                    await _repo.deleteCertification(id);
                    if (!mounted) return;
                    setState(_loadFromRepo);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _openExperienceSheet();
              break;
            case 1:
              _openEducationSheet();
              break;
            case 2:
              _openProjectSheet();
              break;
            case 3:
              _openCertificationSheet();
              break;
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final missing = <String>[];
    if (_photo == null) missing.add('Add Photo');
    if (_experience.isEmpty) missing.add('Add Experience');
    if (_projects.isEmpty) missing.add('Add Project');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: _photo,
                  child: _photo == null
                      ? const Icon(Icons.camera_alt_rounded, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _editInlineText(
                        label: 'Name',
                        initial: _name,
                        onSaved: (value) => setState(() => _name = value),
                      ),
                      child: Text(
                        _name,
                        style: AppTypography.h1(context, isDark: isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _editInlineText(
                        label: 'Headline',
                        initial: _headline,
                        onSaved: (value) => setState(() => _headline = value),
                      ),
                      child: Text(
                        _headline,
                        style: AppTypography.bodySecondary(context, isDark: isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.radiusFull,
                  child: LinearProgressIndicator(
                    value: _completeness,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Text('${(_completeness * 100).round()}% Complete',
                  style: AppTypography.caption(context, isDark: isDark)),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: missing
                .map(
                  (m) => ActionChip(
                    label: Text(m),
                    onPressed: () {
                      if (m.contains('Photo')) _pickPhoto();
                      if (m.contains('Experience')) _openExperienceSheet();
                      if (m.contains('Project')) _openProjectSheet();
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(router.AppRouter.cvPreview),
                  icon: const Icon(Icons.visibility_rounded, size: 20),
                  label: const Text('Preview CV'),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportPdf(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                  label: const Text('Export PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareProfile(context),
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text('Share Profile'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListTab<T>(
    BuildContext context, {
    required bool isDark,
    required List<T> items,
    required String emptyTitle,
    required String emptySubtitle,
    required VoidCallback onAdd,
    required Widget Function(T item) itemBuilder,
    required void Function(int index) onEditAt,
    required void Function(int index) onDeleteAt,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_rounded,
                  size: 64, color: AppColors.primary.withOpacity(0.4)),
              const SizedBox(height: AppSpacing.m),
              Text(emptyTitle, style: AppTypography.h2(context, isDark: isDark)),
              const SizedBox(height: 4),
              Text(
                emptySubtitle,
                style: AppTypography.bodySecondary(context, isDark: isDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey('${T.toString()}-$index'),
          background: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: AppRadius.radiusL,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            onDeleteAt(index);
            return false;
          },
          child: GestureDetector(
            onTap: () => onEditAt(index),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: itemBuilder(items[index]),
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final client = sl<BackendApiClient>();
    if (!client.isAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to export PDF')),
        );
      }
      return;
    }
    try {
      final body = {
        'profile': {
          'name': _name,
          'headline': _headline,
          'email': '',
          'slug': 'profile',
        },
        'skills': <Map<String, dynamic>>[],
        'experience': _experience.map((e) => {
          'role': e.role,
          'company': e.company,
          'period': e.period,
          'summary': e.summary,
        }).toList(),
        'education': _education.map((e) => {
          'degree': e.degree,
          'institution': e.institution,
          'period': e.period,
          'summary': e.summary,
        }).toList(),
        'projects': _projects.map((p) => {
          'name': p.title,
          'description': p.description,
          'url': p.url,
        }).toList(),
        'certifications': _certs.map((c) => {
          'name': c.name,
          'issuer': c.issuer,
          'date': c.date,
        }).toList(),
      };
      final bytes = await client.postBinary('/api/portfolio/export-pdf', body);
      if (!context.mounted) return;
      await Share.shareXFiles(
        [XFile.fromData(Uint8List.fromList(bytes), name: 'skillbridge-cv.pdf', mimeType: 'application/pdf')],
        subject: 'My CV - SkillBridge',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _shareProfile(BuildContext context) async {
    const url = 'https://skillupkenya.com/u/profile';
    await Share.share('Check out my SkillUp Kenya profile: $url', subject: 'My SkillBridge profile');
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (xfile == null || !mounted) return;
    setState(() {
      _photo = FileImage(File(xfile.path));
    });
  }

  Future<void> _editInlineText({
    required String label,
    required String initial,
    required ValueChanged<String> onSaved,
  }) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) {
      onSaved(value);
    }
  }

  Future<void> _openExperienceSheet({_ExperienceEntry? existing, int? index}) async {
    final result = await _showEntrySheet<_ExperienceEntry>(
      title: existing == null ? 'Add Experience' : 'Edit Experience',
      builder: (context, onSave) => _ExperienceForm(
        initial: existing,
        onSubmit: onSave,
      ),
    );
    if (result == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (index != null) {
      final id = _repo.listExperience().elementAt(index).id;
      await _repo.upsertExperience(
        PortfolioExperience(
          id: id,
          role: result.role,
          company: result.company,
          period: result.period,
          summary: result.summary,
          updatedAtMs: now,
        ),
      );
    } else {
      await _repo.createExperience(
        role: result.role,
        company: result.company,
        period: result.period,
        summary: result.summary,
      );
    }
    if (!mounted) return;
    setState(_loadFromRepo);
  }

  Future<void> _openEducationSheet({_EducationEntry? existing, int? index}) async {
    final result = await _showEntrySheet<_EducationEntry>(
      title: existing == null ? 'Add Education' : 'Edit Education',
      builder: (context, onSave) => _EducationForm(
        initial: existing,
        onSubmit: onSave,
      ),
    );
    if (result == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (index != null) {
      final id = _repo.listEducation().elementAt(index).id;
      await _repo.upsertEducation(
        PortfolioEducation(
          id: id,
          degree: result.degree,
          institution: result.institution,
          period: result.period,
          summary: result.summary,
          updatedAtMs: now,
        ),
      );
    } else {
      await _repo.createEducation(
        degree: result.degree,
        institution: result.institution,
        period: result.period,
        summary: result.summary,
      );
    }
    if (!mounted) return;
    setState(_loadFromRepo);
  }

  Future<void> _openProjectSheet({_ProjectEntry? existing, int? index}) async {
    final result = await _showEntrySheet<_ProjectEntry>(
      title: existing == null ? 'Add Project' : 'Edit Project',
      builder: (context, onSave) => _ProjectForm(
        initial: existing,
        onSubmit: onSave,
      ),
    );
    if (result == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (index != null) {
      final id = _repo.listProjects().elementAt(index).id;
      await _repo.upsertProject(
        PortfolioProject(
          id: id,
          title: result.title,
          description: result.description,
          url: result.url,
          screenshotPath: result.screenshotPath,
          updatedAtMs: now,
        ),
      );
    } else {
      await _repo.createProject(
        title: result.title,
        description: result.description,
        url: result.url,
        screenshotPath: result.screenshotPath,
      );
    }
    if (!mounted) return;
    setState(_loadFromRepo);
  }

  Future<void> _openCertificationSheet({_CertificationEntry? existing, int? index}) async {
    final result = await _showEntrySheet<_CertificationEntry>(
      title: existing == null ? 'Add Certification' : 'Edit Certification',
      builder: (context, onSave) => _CertificationForm(
        initial: existing,
        onSubmit: onSave,
      ),
    );
    if (result == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (index != null) {
      final id = _repo.listCertifications().elementAt(index).id;
      await _repo.upsertCertification(
        PortfolioCertification(
          id: id,
          name: result.name,
          issuer: result.issuer,
          date: result.date,
          updatedAtMs: now,
        ),
      );
    } else {
      await _repo.createCertification(
        name: result.name,
        issuer: result.issuer,
        date: result.date,
      );
    }
    if (!mounted) return;
    setState(_loadFromRepo);
  }

  Future<T?> _showEntrySheet<T>({
    required String title,
    required Widget Function(BuildContext context, ValueChanged<T> onSave) builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: AppTypography.h2(context, isDark: Theme.of(context).brightness == Brightness.dark)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: builder(
                          context,
                          (value) => Navigator.of(context).pop(value),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PortfolioListTile extends StatelessWidget {
  const _PortfolioListTile({
    required this.title,
    required this.subtitle,
    this.description,
  });

  final String title;
  final String subtitle;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.radiusL,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.body(context, isDark: isDark)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption(context, isDark: isDark),
              ),
            ],
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                style: AppTypography.bodySecondary(context, isDark: isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExperienceEntry {
  _ExperienceEntry({
    required this.role,
    required this.company,
    required this.period,
    required this.summary,
  });

  final String role;
  final String company;
  final String period;
  final String summary;
}

class _EducationEntry {
  _EducationEntry({
    required this.degree,
    required this.institution,
    required this.period,
    required this.summary,
  });

  final String degree;
  final String institution;
  final String period;
  final String summary;
}

class _ProjectEntry {
  _ProjectEntry({
    required this.title,
    required this.description,
    this.url,
    this.screenshotPath,
  });

  final String title;
  final String description;
  final String? url;
  final String? screenshotPath;
}

class _CertificationEntry {
  _CertificationEntry({
    required this.name,
    this.issuer,
    this.date,
  });

  final String name;
  final String? issuer;
  final String? date;
}

class _ExperienceForm extends StatefulWidget {
  const _ExperienceForm({this.initial, required this.onSubmit});

  final _ExperienceEntry? initial;
  final ValueChanged<_ExperienceEntry> onSubmit;

  @override
  State<_ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<_ExperienceForm> {
  late final TextEditingController _role;
  late final TextEditingController _company;
  late final TextEditingController _period;
  late final TextEditingController _summary;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _role = TextEditingController(text: widget.initial?.role ?? '');
    _company = TextEditingController(text: widget.initial?.company ?? '');
    _period = TextEditingController(text: widget.initial?.period ?? '');
    _summary = TextEditingController(text: widget.initial?.summary ?? '');
  }

  @override
  void dispose() {
    _role.dispose();
    _company.dispose();
    _period.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _role,
          decoration: const InputDecoration(labelText: 'Role'),
        ),
        TextField(
          controller: _company,
          decoration: const InputDecoration(labelText: 'Company'),
        ),
        TextField(
          controller: _period,
          readOnly: false,
          decoration: const InputDecoration(labelText: 'Period (e.g. 2023 - Present)'),
        ),
        TextField(
          controller: _summary,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'What did you do?'),
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() => _saving = true);
                    widget.onSubmit(
                      _ExperienceEntry(
                        role: _role.text.trim(),
                        company: _company.text.trim(),
                        period: _period.text.trim(),
                        summary: _summary.text.trim(),
                      ),
                    );
                  },
            child: _saving ? const CircularProgressIndicator.adaptive() : const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class _EducationForm extends StatefulWidget {
  const _EducationForm({this.initial, required this.onSubmit});

  final _EducationEntry? initial;
  final ValueChanged<_EducationEntry> onSubmit;

  @override
  State<_EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<_EducationForm> {
  late final TextEditingController _degree;
  late final TextEditingController _institution;
  late final TextEditingController _period;
  late final TextEditingController _summary;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _degree = TextEditingController(text: widget.initial?.degree ?? '');
    _institution = TextEditingController(text: widget.initial?.institution ?? '');
    _period = TextEditingController(text: widget.initial?.period ?? '');
    _summary = TextEditingController(text: widget.initial?.summary ?? '');
  }

  @override
  void dispose() {
    _degree.dispose();
    _institution.dispose();
    _period.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _degree,
          decoration: const InputDecoration(labelText: 'Degree / Course'),
        ),
        TextField(
          controller: _institution,
          decoration: const InputDecoration(labelText: 'Institution'),
        ),
        TextField(
          controller: _period,
          decoration: const InputDecoration(labelText: 'Period'),
        ),
        TextField(
          controller: _summary,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Details (optional)'),
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() => _saving = true);
                    widget.onSubmit(
                      _EducationEntry(
                        degree: _degree.text.trim(),
                        institution: _institution.text.trim(),
                        period: _period.text.trim(),
                        summary: _summary.text.trim(),
                      ),
                    );
                  },
            child: _saving ? const CircularProgressIndicator.adaptive() : const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class _ProjectForm extends StatefulWidget {
  const _ProjectForm({this.initial, required this.onSubmit});

  final _ProjectEntry? initial;
  final ValueChanged<_ProjectEntry> onSubmit;

  @override
  State<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<_ProjectForm> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _url;
  String? _screenshotPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _description = TextEditingController(text: widget.initial?.description ?? '');
    _url = TextEditingController(text: widget.initial?.url ?? '');
    _screenshotPath = widget.initial?.screenshotPath;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _screenshotPath = image.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Project title'),
        ),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        TextField(
          controller: _url,
          decoration: const InputDecoration(labelText: 'URL (optional)'),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppSpacing.s),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _pickScreenshot,
            icon: const Icon(Icons.image_rounded),
            label: Text(_screenshotPath == null ? 'Add screenshot' : 'Change screenshot'),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() => _saving = true);
                    widget.onSubmit(
                      _ProjectEntry(
                        title: _title.text.trim(),
                        description: _description.text.trim(),
                        url: _url.text.trim().isEmpty ? null : _url.text.trim(),
                        screenshotPath: _screenshotPath,
                      ),
                    );
                  },
            child: _saving ? const CircularProgressIndicator.adaptive() : const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class _CertificationForm extends StatefulWidget {
  const _CertificationForm({this.initial, required this.onSubmit});

  final _CertificationEntry? initial;
  final ValueChanged<_CertificationEntry> onSubmit;

  @override
  State<_CertificationForm> createState() => _CertificationFormState();
}

class _CertificationFormState extends State<_CertificationForm> {
  late final TextEditingController _name;
  late final TextEditingController _issuer;
  late final TextEditingController _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _issuer = TextEditingController(text: widget.initial?.issuer ?? '');
    _date = TextEditingController(text: widget.initial?.date ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _issuer.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Certification name'),
        ),
        TextField(
          controller: _issuer,
          decoration: const InputDecoration(labelText: 'Issuer (optional)'),
        ),
        TextField(
          controller: _date,
          decoration: const InputDecoration(labelText: 'Date (optional)'),
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() => _saving = true);
                    widget.onSubmit(
                      _CertificationEntry(
                        name: _name.text.trim(),
                        issuer: _issuer.text.trim().isEmpty ? null : _issuer.text.trim(),
                        date: _date.text.trim().isEmpty ? null : _date.text.trim(),
                      ),
                    );
                  },
            child: _saving ? const CircularProgressIndicator.adaptive() : const Text('Save'),
          ),
        ),
      ],
    );
  }
}

