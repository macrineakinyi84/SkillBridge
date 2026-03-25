import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/models/assessment_question.dart';
/// Quiz: progress, question card, 4 options, 500ms correct/incorrect feedback, no back without confirm.
class AssessmentQuizScreen extends StatefulWidget {
  const AssessmentQuizScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<AssessmentQuizScreen> createState() => _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends State<AssessmentQuizScreen> {
  final AssessmentRepository _repo = sl<AssessmentRepository>();
  List<AssessmentQuestion> _questions = [];
  int _currentIndex = 0;
  final Map<String, int> _answers = {};
  bool _loading = true;
  bool _showingFeedback = false;
  bool? _lastCorrect;

  String get _userId => AuthScope.maybeOf(context)?.state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getQuestions(widget.categoryId);
      if (mounted) setState(() {
        _questions = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onAnswerSelected(int optionIndex) async {
    if (_showingFeedback) return;
    final q = _questions[_currentIndex];
    final correct = optionIndex == q.correctIndex;
    setState(() {
      _answers[q.id] = optionIndex;
      _showingFeedback = true;
      _lastCorrect = correct;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showingFeedback = false);
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    try {
      final result = await _repo.submitAssessment(_userId, widget.categoryId, _answers);
      if (!mounted) return;
      context.push(router.AppRouter.assessmentResult, extra: result);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave assessment?'),
            content: const Text('Your progress will be lost.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Stay')),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Leave')),
            ],
          ),
        );
        if (leave == true && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: AppBar(
          title: Text('Question ${_currentIndex + 1} of ${_questions.length}'),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _questions.isEmpty
                ? const Center(child: Text('No questions'))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                          child: _QuestionCard(
                            question: _questions[_currentIndex],
                            selectedIndex: _answers[_questions[_currentIndex].id],
                            showingFeedback: _showingFeedback,
                            lastCorrect: _lastCorrect,
                            isDark: isDark,
                            onTap: _onAnswerSelected,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedIndex,
    required this.showingFeedback,
    required this.lastCorrect,
    required this.isDark,
    required this.onTap,
  });

  final AssessmentQuestion question;
  final int? selectedIndex;
  final bool showingFeedback;
  final bool? lastCorrect;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (i) {
              final selected = selectedIndex == i;
              Color? bg;
              if (showingFeedback && selected) {
                bg = lastCorrect == true ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: bg ?? (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: AppRadius.radiusM,
                  child: InkWell(
                    borderRadius: AppRadius.radiusM,
                    onTap: selected ? null : () => onTap(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
                        borderRadius: AppRadius.radiusM,
                      ),
                      child: Row(
                        children: [
                          Icon(selected ? (lastCorrect == true ? Icons.check_circle_rounded : Icons.cancel_rounded) : Icons.radio_button_unchecked_rounded, color: selected ? (lastCorrect == true ? AppColors.success : AppColors.error) : AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(question.options[i], style: Theme.of(context).textTheme.bodyLarge)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
