/// A learning path (course) with week-by-week resources.
class LearningPath {
  const LearningPath({
    required this.id,
    required this.title,
    required this.category,
    required this.totalWeeks,
    required this.estimatedHours,
    required this.weeks,
    this.progressPercent = 0,
    this.isRecommended = false,
  });

  final String id;
  final String title;
  final String category;
  final int totalWeeks;
  final double estimatedHours;
  final List<PathWeek> weeks;
  final double progressPercent;
  final bool isRecommended;
}

/// One week in a path: list of resources.
class PathWeek {
  const PathWeek({
    required this.weekNumber,
    required this.resources,
    this.isUnlocked = true,
    this.isCompleted = false,
  });

  final int weekNumber;
  final List<PathResource> resources;
  final bool isUnlocked;
  final bool isCompleted;
}

/// Single resource (video/article/quiz) in a week.
class PathResource {
  const PathResource({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    this.url,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final ResourceType type;
  final int durationMinutes;
  final String? url;
  final bool isCompleted;
}

enum ResourceType { video, article, quiz }
