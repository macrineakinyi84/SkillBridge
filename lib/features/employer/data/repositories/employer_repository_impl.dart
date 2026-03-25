import '../datasources/employer_remote_datasource.dart';
import '../models/employer_dashboard_model.dart';
import '../models/job_listing_model.dart';
import '../models/candidate_model.dart';
import '../models/talent_pool_search_result.dart';
import '../../domain/repositories/employer_repository.dart';

/// Delegates to EmployerRemoteDataSource (mock or real API); see employer_remote_datasource.dart.
class EmployerRepositoryImpl implements EmployerRepository {
  EmployerRepositoryImpl(this._remote);

  final EmployerRemoteDataSource _remote;

  @override
  Future<EmployerDashboardModel> getDashboard(String employerId) =>
      _remote.getDashboard(employerId);

  @override
  Future<List<JobListingModel>> getListings(String employerId) =>
      _remote.getListings(employerId);

  @override
  Future<void> updateApplicationStatus(String applicationId, String status) =>
      _remote.patchApplicationStatus(applicationId, status);

  @override
  Future<List<CandidateModel>> getCandidatesByJob(String jobId) =>
      _remote.getCandidatesByJob(jobId);

  @override
  Future<CandidateModel?> getCandidateByApplicationId(String applicationId) =>
      _remote.getCandidateByApplicationId(applicationId);

  @override
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
  }) =>
      _remote.createOrUpdateListing(
        employerId: employerId,
        listingId: listingId,
        title: title,
        description: description,
        requiredSkillIds: requiredSkillIds,
        county: county,
        type: type,
        deadline: deadline,
        remote: remote,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        requirements: requirements,
        skillIdToMinScore: skillIdToMinScore,
      );

  @override
  Future<int> getMatchingCandidateCount(Map<String, int> skillIdToMinScore) =>
      _remote.getMatchingCandidateCount(skillIdToMinScore);

  @override
  Future<({List<TalentPoolSearchResult> items, int total})> getTalentPoolSearch({
    String? county,
    String? categoryId,
    String? q,
    int limit = 20,
    int offset = 0,
  }) =>
      _remote.getTalentPoolSearch(county: county, categoryId: categoryId, q: q, limit: limit, offset: offset);
}
