/// Daily micro-lesson for the Learning Hub "Today's Lesson" card.
class MicroLesson {
  const MicroLesson({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.category,
    required this.skillImproved,
    this.content,
    this.keyTerms,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final String category;
  final String skillImproved;
  final String? content;
  final List<String>? keyTerms;
}
