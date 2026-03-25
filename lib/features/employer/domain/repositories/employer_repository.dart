import '../../data/models/employer_dashboard_model.dart';
import '../../data/models/job_listing_model.dart';
import '../../data/models/application_model.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/talent_pool_search_result.dart';

/// Employer use cases: dashboard stats, listings CRUD, application status, candidates by job.
abstract class EmployerRepository {
  Future<EmployerDashboardModel> getDashboard(String employerId);
  Future<List<JobListingModel>> getListings(String employerId);
  Future<void> updateApplicationStatus(String applicationId, String status);
  Future<List<CandidateModel>> getCandidatesByJob(String jobId);
  Future<CandidateModel?> getCandidateByApplicationId(String applicationId);
  Future<JobListingModel?> createOrUpdateListing({
    required String employerId,
    String? listingId,
    required String title,
    required String description,
    required List<String> requiredSkillIds,
    required String county,
    required String type,
    required DateTime deadline,
    bool remote = false,
    int? salaryMin,
    int? salaryMax,
    List<String>? requirements,
    Map<String, int>? skillIdToMinScore,
  });

  /// Live preview: how many candidates match the given skill minimums (e.g. for Post Job step 2).
  Future<int> getMatchingCandidateCount(Map<String, int> skillIdToMinScore);

  /// Talent pool search (GET /api/employer/talent-pool). Returns items and total.
  Future<({List<TalentPoolSearchResult> items, int total})> getTalentPoolSearch({
    String? county,
    String? categoryId,
    String? q,
    int limit = 20,
    int offset = 0,
  });
}
