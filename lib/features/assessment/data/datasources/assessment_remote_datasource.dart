import '../../../../core/network/backend_api_client.dart';
import '../../../../core/network/backend_auth_api.dart';
import '../../domain/models/assessment_category.dart';
import '../../domain/models/assessment_question.dart';
import '../../domain/models/assessment_result.dart';

abstract class AssessmentRemoteDataSource {
  Future<List<AssessmentCategory>> getCategories(String? userId);
  Future<List<AssessmentQuestion>> getQuestions(String categoryId);
  Future<AssessmentResult> submitAssessment(String studentId, String categoryId, Map<String, int> answers);
}

class AssessmentRemoteDataSourceMock implements AssessmentRemoteDataSource {
  final Map<String, int> _scores = {};
  final Map<String, DateTime> _lastAssessed = {};

  @override
  Future<List<AssessmentCategory>> getCategories(String? userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    const ids = [
      'digital-literacy',
      'communication',
      'business-entrepreneurship',
      'technical-ict',
      'soft-skills-leadership',
    ];
    const names = [
      'Digital Literacy',
      'Communication',
      'Business & Entrepreneurship',
      'Technical (ICT)',
      'Soft Skills & Leadership',
    ];
    return List.generate(5, (i) => AssessmentCategory(
      id: ids[i],
      name: names[i],
      iconName: ids[i],
      currentScore: _scores[ids[i]],
      tier: _scores[ids[i]] != null ? _tierFor(_scores[ids[i]]!) : null,
      lastAssessedAt: _lastAssessed[ids[i]],
    ));
  }

  String _tierFor(int s) {
    if (s >= 80) return 'Advanced';
    if (s >= 60) return 'Proficient';
    if (s >= 40) return 'Developing';
    return 'Beginner';
  }

  @override
  Future<List<AssessmentQuestion>> getQuestions(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.generate(15, (i) => AssessmentQuestion(
      id: '$categoryId-q-$i',
      text: 'Sample question ${i + 1} for this category?',
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correctIndex: i % 4,
      difficulty: i % 3 == 0 ? 'hard' : i % 3 == 1 ? 'medium' : 'easy',
    ));
  }

  @override
  Future<AssessmentResult> submitAssessment(String studentId, String categoryId, Map<String, int> answers) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final questions = await getQuestions(categoryId);
    int rawScore = 0;
    int maxPossible = 0;
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final pts = q.difficulty == 'hard' ? 3 : q.difficulty == 'medium' ? 2 : 1;
      maxPossible += pts;
      final ans = answers[q.id] ?? answers[i.toString()];
      if (ans == q.correctIndex) rawScore += pts;
    }
    final normalisedScore = maxPossible > 0 ? (rawScore / maxPossible * 100).round() : 0;
    final tier = _tierFor(normalisedScore);
    final previous = _scores[categoryId];
    _scores[categoryId] = normalisedScore;
    _lastAssessed[categoryId] = DateTime.now();
    final scoreChange = previous != null ? normalisedScore - previous : null;
    final xpAwarded = 50 + (scoreChange != null && scoreChange > 0 ? 30 : 0);
    const catIds = ['digital-literacy', 'communication', 'business-entrepreneurship', 'technical-ict', 'soft-skills-leadership'];
    final rd = [0.72, 0.65, 0.58, 0.80, 0.55];
    final idx = catIds.indexOf(categoryId);
    if (idx >= 0) rd[idx] = normalisedScore / 100.0;
    return AssessmentResult(
      normalisedScore: normalisedScore,
      rawScore: rawScore,
      maxPossibleScore: maxPossible,
      tier: tier,
      previousScore: previous,
      scoreChange: scoreChange,
      gaps: [
        GapItem(categoryId: 'technical-ict', gapPoints: 15, benchmark: 70, currentScore: 55),
        GapItem(categoryId: 'communication', gapPoints: 10, benchmark: 60, currentScore: 50),
      ],
      recommendations: [
        LearningRecommendation(categoryId: 'technical-ict', title: 'Improve Technical (ICT)', gapPoints: 15),
        LearningRecommendation(categoryId: 'communication', title: 'Improve Communication', gapPoints: 10),
      ],
      xpAwarded: xpAwarded,
      radarData: rd,
    );
  }
}

/// Uses backend POST /api/assessments/score when authenticated; falls back to mock otherwise.
class AssessmentRemoteDataSourceBackend implements AssessmentRemoteDataSource {
  AssessmentRemoteDataSourceBackend(this._client, this._mock);

  final BackendApiClient _client;
  final AssessmentRemoteDataSourceMock _mock;

  @override
  Future<List<AssessmentCategory>> getCategories(String? userId) async {
    try {
      final list = await BackendAuthApi.getCategories();
      return list.map((m) => AssessmentCategory(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        iconName: m['icon'] as String? ?? m['id'] as String? ?? '',
        currentScore: m['currentScore'] as int?,
        tier: m['tier'] as String?,
      )).toList();
    } catch (_) {
      return _mock.getCategories(userId);
    }
  }

  @override
  Future<List<AssessmentQuestion>> getQuestions(String categoryId) async {
    try {
      final list = await BackendAuthApi.getQuestions(categoryId);
      return list.map((m) => AssessmentQuestion(
        id: m['id'] as String? ?? '',
        text: m['text'] as String? ?? '',
        options: (m['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        correctIndex: (m['correctIndex'] as num?)?.toInt() ?? 0,
        difficulty: m['difficulty'] as String? ?? 'medium',
      )).toList();
    } catch (_) {
      return _mock.getQuestions(categoryId);
    }
  }

  @override
  Future<AssessmentResult> submitAssessment(
      String studentId, String categoryId, Map<String, int> answers) async {
    if (!_client.isAuthenticated) {
      return _mock.submitAssessment(studentId, categoryId, answers);
    }
    try {
      // Prefer full submit endpoint (persists, awards XP, returns gaps/radar).
      final res = await _client.post('/api/assessments/submit', {
        'categoryId': categoryId,
        'answers': answers,
      });
      final data = res['data'] as Map<String, dynamic>? ?? {};
      return _parseAssessmentResult(data, categoryId);
    } on BackendApiException catch (_) {
      // Fallback: score-only endpoint with mock questions
      try {
        final questions = await getQuestions(categoryId);
        final questionsJson = questions
            .map((q) => {
                  'id': q.id,
                  'difficulty': q.difficulty,
                  'correctIndex': q.correctIndex,
                })
            .toList();
        final res = await _client.post('/api/assessments/score', {
          'answers': answers,
          'questions': questionsJson,
        });
        final data = res['data'] as Map<String, dynamic>? ?? {};
        return _parseAssessmentResult(data, categoryId);
      } on BackendApiException catch (_) {
        return _mock.submitAssessment(studentId, categoryId, answers);
      }
    }
  }

  AssessmentResult _parseAssessmentResult(Map<String, dynamic> data, String categoryId) {
    final score = data['normalisedScore'] as int? ?? data['score'] as int? ?? 0;
    final rawScore = data['rawScore'] as int? ?? 0;
    final maxPossibleScore = data['maxPossibleScore'] as int? ?? 1;
    final tier = data['tier'] as String? ?? 'Beginner';
    final previousScore = data['previousScore'] as int?;
    final scoreChange = data['scoreChange'] as int?;
    final xpAwarded = data['xpAwarded'] as int? ?? 50;

    final gapsList = data['gaps'] as List<dynamic>? ?? [];
    final gaps = gapsList.map((g) {
      final m = (g as Map).cast<String, dynamic>();
      return GapItem(
        categoryId: m['categoryId'] as String? ?? '',
        gapPoints: (m['gapPoints'] as num?)?.toInt() ?? 0,
        benchmark: (m['benchmark'] as num?)?.toInt(),
        currentScore: (m['currentScore'] as num?)?.toInt(),
      );
    }).toList();

    final recsList = data['recommendations'] as List<dynamic>? ?? [];
    final recommendations = recsList.map((r) {
      final m = (r as Map).cast<String, dynamic>();
      return LearningRecommendation(
        categoryId: m['categoryId'] as String? ?? '',
        title: m['title'] as String? ?? '',
        gapPoints: (m['gapPoints'] as num?)?.toInt(),
      );
    }).toList();

    List<double> rd = [0.72, 0.65, 0.58, 0.80, 0.55];
    final radarData = data['radarData'] as List<dynamic>?;
    if (radarData != null && radarData.isNotEmpty) {
      rd = radarData.map((e) => (e as num).toDouble()).toList();
    } else {
      const catIds = [
        'digital-literacy',
        'communication',
        'business-entrepreneurship',
        'technical-ict',
        'soft-skills-leadership',
      ];
      final idx = catIds.indexOf(categoryId);
      if (idx >= 0) rd[idx] = score / 100.0;
    }

    return AssessmentResult(
      normalisedScore: score,
      rawScore: rawScore,
      maxPossibleScore: maxPossibleScore,
      tier: tier,
      previousScore: previousScore,
      scoreChange: scoreChange,
      gaps: gaps,
      recommendations: recommendations,
      xpAwarded: xpAwarded,
      radarData: rd,
    );
  }
}