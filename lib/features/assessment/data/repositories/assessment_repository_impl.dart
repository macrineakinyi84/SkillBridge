import '../../domain/models/assessment_category.dart';
import '../../domain/models/assessment_question.dart';
import '../../domain/models/assessment_result.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/assessment_remote_datasource.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  AssessmentRepositoryImpl(this._remote);
  final AssessmentRemoteDataSource _remote;

  @override
  Future<List<AssessmentCategory>> getCategories(String? userId) =>
      _remote.getCategories(userId);

  @override
  Future<List<AssessmentQuestion>> getQuestions(String categoryId) =>
      _remote.getQuestions(categoryId);

  @override
  Future<AssessmentResult> submitAssessment(String studentId, String categoryId, Map<String, int> answers) =>
      _remote.submitAssessment(studentId, categoryId, answers);
}
