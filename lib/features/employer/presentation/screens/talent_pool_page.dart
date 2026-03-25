import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../data/models/talent_pool_search_result.dart';
import '../../domain/repositories/employer_repository.dart';

/// Talent pool search: list of candidates (students) for recruiters. Read-only list; tap to view profile.
class TalentPoolPage extends StatefulWidget {
  const TalentPoolPage({super.key});

  @override
  State<TalentPoolPage> createState() => _TalentPoolPageState();
}

class _TalentPoolPageState extends State<TalentPoolPage> {
  final EmployerRepository _repo = sl<EmployerRepository>();
  List<TalentPoolSearchResult> _items = [];
  int _total = 0;
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String? q}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.getTalentPoolSearch(q: q, limit: 50, offset: 0);
      if (mounted) setState(() {
        _items = result.items;
        _total = result.total;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Talent pool'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.s),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? AppColors.backgroundDark : Colors.white,
              ),
              onSubmitted: (v) => _load(q: v.isEmpty ? null : v),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.m),
                        FilledButton(onPressed: () => _load(), child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _load(q: _searchController.text.isEmpty ? null : _searchController.text),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    children: [
                      Text('$_total candidate${_total == 1 ? '' : 's'}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                      const SizedBox(height: AppSpacing.s),
                      ..._items.map((item) => _CandidateTile(
                            item: item,
                            isDark: isDark,
                            onTap: () => context.push('/employer/candidate/view/${item.id}'),
                          )),
                    ],
                  ),
                ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.item, required this.isDark, required this.onTap});
  final TalentPoolSearchResult item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = item.displayName ?? 'Candidate';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.radiusL,
        child: InkWell(
          borderRadius: AppRadius.radiusL,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    (name.isNotEmpty ? name[0] : '?').toUpperCase(),
                    style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      if (item.county != null) Text(item.county!, style: Theme.of(context).textTheme.bodySmall),
                      if (item.levelName != null) Text('Level ${item.level ?? 0} • ${item.levelName}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
