import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../student_data/data/repositories/student_skills_repository.dart';
import '../../../student_data/domain/models/student_skill.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/widgets/empty_state.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final StudentSkillsRepository _repo = sl<StudentSkillsRepository>();
  List<StudentSkill> _skills = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _skills = _repo.list();
    });
  }

  Future<void> _openAddSkillSheet() async {
    final result = await showModalBottomSheet<_AddSkillResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.m,
          right: AppSpacing.m,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.m,
          top: AppSpacing.s,
        ),
        child: const _AddSkillForm(),
      ),
    );
    if (result == null) return;
    final created = await _repo.create(
      name: result.name,
      level: result.level,
      progress: result.progress,
    );
    if (!mounted) return;
    setState(() {
      _skills = [created, ..._skills];
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSkills = _skills.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Skills',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        elevation: 0,
      ),
      body: hasSkills
          ? _buildSkillsList(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: InkWell(
                      onTap: () => context.push('${router.AppRouter.skills}/categories'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.quiz_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Skills Assessment', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  Text('Browse categories (Tech, Soft, Business). Take assessment, view results.', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  EmptyState(
                    icon: Icons.psychology_rounded,
                    iconColor: AppColors.primary,
                    headline: 'No skills yet',
                    body: 'Add your first skill to see progress here and improve your readiness score.',
                    actionLabel: 'Add skill',
                    onAction: _openAddSkillSheet,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSkillsList(BuildContext context) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        const SizedBox(height: AppSpacing.m),
        FilledButton.icon(
          onPressed: _openAddSkillSheet,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add skill'),
        ),
        const SizedBox(height: AppSpacing.m),
        ..._skills.map((s) => _SkillTile(
              skill: s,
              onDelete: () async {
                await _repo.delete(s.id);
                if (!mounted) return;
                _reload();
              },
            )),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.skill, required this.onDelete});
  final StudentSkill skill;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(skill.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${skill.level} • ${skill.progress}%', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (skill.progress.clamp(0, 100)) / 100,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSkillForm extends StatefulWidget {
  const _AddSkillForm();

  @override
  State<_AddSkillForm> createState() => _AddSkillFormState();
}

class _AddSkillFormState extends State<_AddSkillForm> {
  final _name = TextEditingController();
  String _level = 'Beginner';
  double _progress = 40;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Add skill', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.m),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Skill name (e.g. Flutter)'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.m),
        DropdownButtonFormField<String>(
          value: _level,
          items: const [
            DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
            DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
            DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
          ],
          onChanged: (v) => setState(() => _level = v ?? 'Beginner'),
          decoration: const InputDecoration(labelText: 'Level'),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('Progress: ${_progress.round()}%', style: Theme.of(context).textTheme.bodySmall),
        Slider(
          value: _progress,
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (v) => setState(() => _progress = v),
        ),
        const SizedBox(height: AppSpacing.m),
        FilledButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pop(_AddSkillResult(name: name, level: _level, progress: _progress.round()));
          },
          child: const Text('Save'),
        ),
        const SizedBox(height: AppSpacing.s),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _AddSkillResult {
  const _AddSkillResult({required this.name, required this.level, required this.progress});
  final String name;
  final String level;
  final int progress;
}
