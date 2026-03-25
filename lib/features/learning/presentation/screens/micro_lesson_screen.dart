import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/auth_scope.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';
import '../../domain/models/micro_lesson.dart';
import '../../data/learning_mock_data.dart';

/// Full-screen micro-lesson: reading progress, formatted content, Mark complete / Skip today.
class MicroLessonScreen extends StatefulWidget {
  const MicroLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<MicroLessonScreen> createState() => _MicroLessonScreenState();
}

class _MicroLessonScreenState extends State<MicroLessonScreen> {
  final ScrollController _scrollController = ScrollController();
  MicroLesson? _lesson;
  double _readProgress = 0;
  bool _completed = false;
  bool _skipUsed = false;
  static const int _skipLimitPerWeek = 2;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    _scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLesson() {
    final lesson = LearningMockData.todaysLesson;
    if (lesson.id == widget.lessonId) {
      setState(() => _lesson = lesson);
    }
  }

  void _updateProgress() {
    if (_lesson?.content == null) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max > 0) {
      setState(() => _readProgress = (offset / max).clamp(0.0, 1.0));
    }
  }

  Future<void> _markComplete() async {
    final userId = AuthScope.maybeOf(context)?.state.user?.id ?? '';
    if (userId.isNotEmpty) {
      final repo = sl<GamificationRepository>();
      await repo.awardXp(userId, 'micro_lesson_completed');
      await repo.updateStreak(userId, 'learn');
    }
    setState(() => _completed = true);
    if (!mounted) return;
    final skillImproved = _lesson?.skillImproved ?? 'Communication';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('+30 XP • Learn streak updated • Contributes to: $skillImproved')),
    );
    context.pop();
  }

  void _skipToday() {
    if (_skipUsed) return;
    setState(() => _skipUsed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skipped today. Use sparingly (< 2x per week) to keep your streak.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final lesson = _lesson!;
    final content = lesson.content ?? 'No content for this lesson.';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(lesson.title),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _readProgress,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.m),
              child: _FormattedContent(
                content: content,
                keyTerms: lesson.keyTerms ?? [],
                isDark: isDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _completed ? null : () => _markComplete(),
                          child: const Text('Mark as Complete'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      TextButton(
                        onPressed: _skipUsed ? null : _skipToday,
                        child: Text('Skip today'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Completing awards 30 XP and updates your learn streak. This lesson improves: ${lesson.skillImproved}',
                    style: AppTypography.caption(context, isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders content with **key terms** bolded.
class _FormattedContent extends StatelessWidget {
  const _FormattedContent({
    required this.content,
    required this.keyTerms,
    required this.isDark,
  });

  final String content;
  final List<String> keyTerms;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final children = <Widget>[];
    for (final line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: AppSpacing.s));
        continue;
      }
      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.xs),
            child: Text(
              line.replaceAll('**', ''),
              style: AppTypography.h2(context, isDark: isDark),
            ),
          ),
        );
        continue;
      }
      final spans = _parseBold(line, context, isDark);
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: RichText(
            text: TextSpan(style: AppTypography.body(context, isDark: isDark), children: spans),
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  List<TextSpan> _parseBold(String text, BuildContext context, bool isDark) {
    final re = RegExp(r'\*\*(.+?)\*\*');
    final spans = <TextSpan>[];
    int start = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start), style: AppTypography.body(context, isDark: isDark)));
      }
      spans.add(TextSpan(text: m.group(1), style: AppTypography.body(context, isDark: isDark).copyWith(fontWeight: FontWeight.w700)));
      start = m.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: AppTypography.body(context, isDark: isDark)));
    }
    return spans.isEmpty ? [TextSpan(text: text, style: AppTypography.body(context, isDark: isDark))] : spans;
  }
}
