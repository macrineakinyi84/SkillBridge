import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../data/constants/kenyan_counties.dart';
import '../../data/models/job_listing_model.dart';
import '../../domain/repositories/employer_repository.dart';

/// Multi-step Post Job: (1) Job Details, (2) Required Skills + live match count, (3) Review & Post.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key, this.editListingId});

  final String? editListingId;

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  final BackendApiClient _api = sl<BackendApiClient>();
  int _step = 0;
  bool _saving = false;
  bool _billingLoading = true;
  bool _canPostJobs = false;
  String _plan = 'free';
  JobListingModel? _editListing;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  String _jobType = 'Full-time';
  String? _county;
  bool _remote = false;
  DateTime? _deadline;
  int _salaryMin = 0;
  int _salaryMax = 100000;
  bool _showSalary = false;

  static const _skillCategories = [
    ('digital-literacy', 'Digital Literacy'),
    ('communication', 'Communication'),
    ('business-entrepreneurship', 'Business & Entrepreneurship'),
    ('technical-ict', 'Technical (ICT)'),
    ('soft-skills-leadership', 'Soft Skills & Leadership'),
  ];
  final Map<String, bool> _skillEnabled = {};
  final Map<String, int> _skillMinScore = {};

  int _matchingCount = 0;
  bool _termsAccepted = false;

  String get _employerId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    for (final e in _skillCategories) {
      _skillEnabled[e.$1] = false;
      _skillMinScore[e.$1] = 50;
    }
    if (widget.editListingId != null) _loadForEdit();
    _refreshMatchCount();
    _loadBillingStatus();
  }

  Future<void> _loadBillingStatus() async {
    try {
      final res = await _api.get('/api/billing/status');
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (!mounted) return;
      setState(() {
        _plan = (data['plan'] as String?) ?? 'free';
        _canPostJobs = (data['canPostJobs'] as bool?) ?? false;
        _billingLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plan = 'free';
        _canPostJobs = false;
        _billingLoading = false;
      });
    }
  }

  Future<void> _startCheckout() async {
    try {
      final res = await _api.post('/api/billing/create-checkout-session', {});
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) throw Exception('Checkout URL missing');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to start checkout: $e')));
    }
  }

  Future<void> _loadForEdit() async {
    final list = await _repo.getListings(_employerId);
    for (final l in list) {
      if (l.id == widget.editListingId) {
        setState(() {
          _editListing = l;
          _titleController.text = l.title;
          _descriptionController.text = l.description;
          _county = l.county;
          _jobType = l.type;
          _deadline = l.deadline;
          for (final id in l.requiredSkillIds) {
            _skillEnabled[id] = true;
          }
        });
        break;
      }
    }
  }

  Future<void> _refreshMatchCount() async {
    final map = <String, int>{};
    for (final e in _skillCategories) {
      if (_skillEnabled[e.$1] == true) map[e.$1] = _skillMinScore[e.$1]!;
    }
    if (map.isEmpty) {
      setState(() => _matchingCount = 0);
      return;
    }
    final count = await _repo.getMatchingCandidateCount(map);
    if (mounted) setState(() => _matchingCount = count);
  }

  Map<String, int> get _skillIdToMinScore {
    final map = <String, int>{};
    for (final e in _skillCategories) {
      if (_skillEnabled[e.$1] == true) map[e.$1] = _skillMinScore[e.$1]!;
    }
    return map;
  }

  List<String> get _requiredSkillIds => _skillCategories.map((e) => e.$1).where((id) => _skillEnabled[id] == true).toList();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_step < 2) {
      setState(() => _step++);
      if (_step == 1) _refreshMatchCount();
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter job title')));
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter description')));
      return;
    }
    if (_county == null || _county!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select county')));
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select application deadline')));
      return;
    }
    final minDeadline = DateTime.now().add(const Duration(days: 7));
    if (_deadline!.isBefore(minDeadline)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deadline must be at least 7 days from now')));
      return;
    }
    if (_requiredSkillIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one required skill')));
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept the terms')));
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.createOrUpdateListing(
        employerId: _employerId,
        listingId: widget.editListingId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requiredSkillIds: _requiredSkillIds,
        county: _county!,
        type: _jobType,
        deadline: _deadline!,
        remote: _remote,
        salaryMin: _showSalary ? _salaryMin : null,
        salaryMax: _showSalary ? _salaryMax : null,
        skillIdToMinScore: _skillIdToMinScore,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted')));
        context.go(router.AppRouter.employerListings);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
        title: Text(_editListing != null ? 'Edit job' : 'Post job'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: _billingLoading
          ? const Center(child: CircularProgressIndicator())
          : !_canPostJobs
              ? ListView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Upgrade required', style: AppTypography.h3(context, isDark: isDark)),
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              'Your current plan is ${_plan.toUpperCase()}. Upgrade to Pro to post job listings.',
                              style: AppTypography.body(context, isDark: isDark),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            FilledButton.icon(
                              onPressed: _startCheckout,
                              icon: const Icon(Icons.workspace_premium_rounded),
                              label: const Text('Upgrade to Pro'),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            TextButton(
                              onPressed: _loadBillingStatus,
                              child: const Text('I have already paid, refresh status'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          if (_step == 0) _buildStep1(isDark),
          if (_step == 1) _buildStep2(isDark),
          if (_step == 2) _buildStep3(isDark),
          const SizedBox(height: AppSpacing.l),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_step < 2 ? 'Continue' : 'Post Job'),
          ),
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step--),
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Job Details', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.m),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Job title'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
          maxLines: 5,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: _requirementsController,
          decoration: const InputDecoration(labelText: 'Requirements (one per line)', alignLabelWithHint: true),
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.m),
        Text('Job type', style: AppTypography.body(context, isDark: isDark)),
        const SizedBox(height: 4),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Internship', label: Text('Internship'), icon: Icon(Icons.school_rounded)),
            ButtonSegment(value: 'Full-time', label: Text('Full-time'), icon: Icon(Icons.work_rounded)),
            ButtonSegment(value: 'Part-time', label: Text('Part-time'), icon: Icon(Icons.schedule_rounded)),
            ButtonSegment(value: 'Contract', label: Text('Contract'), icon: Icon(Icons.description_rounded)),
          ],
          selected: {_jobType},
          onSelectionChanged: (s) => setState(() => _jobType = s.first),
        ),
        const SizedBox(height: AppSpacing.m),
        DropdownButtonFormField<String>(
          value: _county,
          decoration: const InputDecoration(labelText: 'County'),
          items: kenyanCounties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _county = v),
          validator: (v) => v == null ? 'Select county' : null,
        ),
        const SizedBox(height: AppSpacing.s),
        SwitchListTile(
          title: const Text('Remote'),
          value: _remote,
          onChanged: (v) => setState(() => _remote = v),
        ),
        const SizedBox(height: AppSpacing.s),
        ListTile(
          title: Text(_deadline != null ? 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}' : 'Application deadline (min 7 days)'),
          trailing: const Icon(Icons.calendar_today_rounded),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _deadline ?? DateTime.now().add(const Duration(days: 14)),
              firstDate: DateTime.now().add(const Duration(days: 7)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _deadline = date);
          },
        ),
        const SizedBox(height: AppSpacing.s),
        CheckboxListTile(
          title: const Text('Include salary range (optional)'),
          value: _showSalary,
          onChanged: (v) => setState(() => _showSalary = v ?? false),
        ),
        if (_showSalary) ...[
          Text('Min: KES ${_salaryMin.toStringAsFixed(0)}', style: AppTypography.caption(context, isDark: isDark)),
          Slider(value: _salaryMin.toDouble(), min: 0, max: 200000, divisions: 40, label: '$_salaryMin', onChanged: (v) => setState(() => _salaryMin = v.round())),
          Text('Max: KES ${_salaryMax.toStringAsFixed(0)}', style: AppTypography.caption(context, isDark: isDark)),
          Slider(value: _salaryMax.toDouble(), min: 0, max: 500000, divisions: 50, label: '$_salaryMax', onChanged: (v) => setState(() => _salaryMax = v.round())),
        ],
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Required Skills', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.s),
        ..._skillCategories.map((e) {
          final id = e.$1;
          final label = e.$2;
          final enabled = _skillEnabled[id] ?? false;
          final score = _skillMinScore[id] ?? 50;
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label, style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w600))),
                      Switch(value: enabled, onChanged: (v) {
                        setState(() {
                          _skillEnabled[id] = v;
                          _refreshMatchCount();
                        });
                      }),
                    ],
                  ),
                  if (enabled) ...[
                    Text('Minimum score: $score', style: AppTypography.caption(context, isDark: isDark)),
                    Slider(
                      value: score.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: '$score',
                      onChanged: (v) {
                        setState(() {
                          _skillMinScore[id] = v.round();
                          _refreshMatchCount();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.m),
        Material(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: AppRadius.radiusL,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              'Based on current students, $_matchingCount candidates match at this level.',
              style: AppTypography.body(context, isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(bool isDark) {
    final requirementsText = _requirementsController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Post', style: AppTypography.h2(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.m),
        _SummaryRow(label: 'Title', value: _titleController.text.trim()),
        _SummaryRow(label: 'Type', value: _jobType),
        _SummaryRow(label: 'County', value: _county ?? '—'),
        _SummaryRow(label: 'Remote', value: _remote ? 'Yes' : 'No'),
        _SummaryRow(label: 'Deadline', value: _deadline != null ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}' : '—'),
        if (_showSalary) _SummaryRow(label: 'Salary', value: 'KES $_salaryMin – $_salaryMax'),
        const SizedBox(height: AppSpacing.s),
        Text('Candidates who will see this: $_matchingCount', style: AppTypography.body(context, isDark: isDark)),
        const SizedBox(height: AppSpacing.m),
        CheckboxListTile(
          title: const Text('I confirm the details and accept the terms for posting this job.'),
          value: _termsAccepted,
          onChanged: (v) => setState(() => _termsAccepted = v ?? false),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
