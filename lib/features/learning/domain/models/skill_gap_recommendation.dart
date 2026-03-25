/// Skill gap from assessment: your score vs benchmark, with learning resources.
class SkillGapRecommendation {
  const SkillGapRecommendation({
    required this.skillName,
    required this.categoryId,
    required this.yourScore,
    required this.benchmarkScore,
    required this.resources,
  });

  final String skillName;
  final String categoryId;
  final int yourScore;
  final int benchmarkScore;
  final List<GapResourceLink> resources;

  int get gapPoints => (benchmarkScore - yourScore).clamp(0, 100);
}

class GapResourceLink {
  const GapResourceLink({
    required this.title,
    required this.url,
    this.type = 'article',
  });

  final String title;
  final String url;
  final String type;
}
