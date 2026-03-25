import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../data/models/job_listing_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Post job form: title, description, required skills (multi-select from categories), county, type, deadline (S-024).
class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key, this.editListingId});

  final String? editListingId;

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countyController = TextEditingController();
  String _type = 'Full-time';
  DateTime? _deadline;
  final Set<String> _selectedSkillIds = {};
  bool _saving = false;
  JobListingModel? _editListing;

  static const List<MapEntry<String, String>> _skillCategories = [
    MapEntry('digital-literacy', 'Digital Literacy'),
    MapEntry('communication', 'Communication'),
    MapEntry('business-entrepreneurship', 'Business & Entrepreneurship'),
    MapEntry('technical-ict', 'Technical (ICT)'),
    MapEntry('soft-skills-leadership', 'Soft Skills & Leadership'),
  ];

  static const List<String> _jobTypes = ['Full-time', 'Part-time', 'Internship', 'Contract'];

  String get _employerId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    if (widget.editListingId != null) _loadForEdit();
  }

  Future<void> _loadForEdit() async {
    final list = await _repo.getListings(_employerId);
    JobListingModel? found;
    for (final l in list) {
      if (l.id == widget.editListingId) {
        found = l;
        break;
      }
    }
    if (found != null && mounted) {
      final listing = found;
      setState(() {
        _editListing = listing;
        _titleController.text = listing.title;
        _descriptionController.text = listing.description;
        _countyController.text = listing.county;
        _type = listing.type;
        _deadline = listing.deadline;
        _selectedSkillIds.addAll(listing.requiredSkillIds);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _countyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a deadline')));
      return;
    }
    if (_selectedSkillIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one required skill category')));
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.createOrUpdateListing(
        employerId: _employerId,
        listingId: widget.editListingId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requiredSkillIds: _selectedSkillIds.toList(),
        county: _countyController.text.trim(),
        type: _type,
        deadline: _deadline!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job saved')));
        context.go(router.AppRouter.employerListings);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          _editListing != null ? 'Edit job' : 'Post job',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Job title',
                border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            Text('Required skills (select categories)', style: AppTypography.h2(context, isDark: isDark)),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: _skillCategories.map((e) {
                final selected = _selectedSkillIds.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) _selectedSkillIds.add(e.key);
                      else _selectedSkillIds.remove(e.key);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.m),
            TextFormField(
              controller: _countyController,
              decoration: InputDecoration(
                labelText: 'County',
                border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter county' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Job type',
                border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
              items: _jobTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: AppSpacing.m),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now().add(const Duration(days: 14)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _deadline = date);
              },
              borderRadius: AppRadius.radiusM,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Application deadline',
                  border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                ),
                child: Text(
                  _deadline != null ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}' : 'Select date',
                  style: AppTypography.body(context, isDark: isDark),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_editListing != null ? 'Save changes' : 'Post job'),
            ),
          ],
        ),
      ),
    );
  }
}

