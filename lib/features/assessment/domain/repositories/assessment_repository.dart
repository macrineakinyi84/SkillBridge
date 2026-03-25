import '../models/assessment_category.dart';
import '../models/assessment_question.dart';
import '../models/assessment_result.dart';

abstract class AssessmentRepository {
  Future<List<AssessmentCategory>> getCategories(String? userId);
  Future<List<AssessmentQuestion>> getQuestions(String categoryId);
  Future<AssessmentResult> submitAssessment(String studentId, String categoryId, Map<String, int> answers);
}
