import 'employer_remote_datasource.dart';
import '../models/employer_dashboard_model.dart';
import '../models/job_listing_model.dart';
import '../models/candidate_model.dart';
import '../models/talent_pool_search_result.dart';

/// Backend-first datasource with safe fallback to mock when backend is unavailable
/// or endpoints are not implemented yet.
class EmployerRemoteDataSourceHybrid implements EmployerRemoteDataSource {
  EmployerRemoteDataSourceHybrid({required this.backend, required this.fallback});

  final EmployerRemoteDataSource backend;
  final EmployerRemoteDataSource fallback;

  @override
  Future<EmployerDashboardModel> getDashboard(String employerId) async {
    try {
      final live = await backend.getDashboard(employerId);
      final isEmpty =
          live.activeListingsCount == 0 &&
          live.totalApplicantsCount == 0 &&
          live.newApplicantsThisWeek == 0 &&
          live.recentApplicants.isEmpty;
      if (isEmpty) {
        return await fallback.getDashboard(employerId);
      }
      return live;
    } catch (_) {
      return await fallback.getDashboard(employerId);
    }
  }

  @override
  Future<List<JobListingModel>> getListings(String employerId) async {
    try {
      return await backend.getListings(employerId);
    } catch (_) {
      return await fallback.getListings(employerId);
    }
  }

  @override
  Future<void> patchApplicationStatus(String applicationId, String status) async {
    try {
      return await backend.patchApplicationStatus(applicationId, status);
    } catch (_) {
      return await fallback.patchApplicationStatus(applicationId, status);
    }
  }

  @override
  Future<List<CandidateModel>> getCandidatesByJob(String jobId) async {
    try {
      return await backend.getCandidatesByJob(jobId);
    } catch (_) {
      return await fallback.getCandidatesByJob(jobId);
    }
  }

  @override
  Future<CandidateModel?> getCandidateByApplicationId(String applicationId) async {
    try {
      return await backend.getCandidateByApplicationId(applicationId);
    } catch (_) {
      return await fallback.getCandidateByApplicationId(applicationId);
    }
  }

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
  }) async {
    try {
      return await backend.createOrUpdateListing(
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
    } catch (_) {
      return await fallback.createOrUpdateListing(
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
    }
  }

  @override
  Future<int> getMatchingCandidateCount(Map<String, int> skillIdToMinScore) async {
    try {
      return await backend.getMatchingCandidateCount(skillIdToMinScore);
    } catch (_) {
      return await fallback.getMatchingCandidateCount(skillIdToMinScore);
    }
  }

  @override
  Future<({List<TalentPoolSearchResult> items, int total})> getTalentPoolSearch({
    String? county,
    String? categoryId,
    String? q,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await backend.getTalentPoolSearch(county: county, categoryId: categoryId, q: q, limit: limit, offset: offset);
    } catch (_) {
      return await fallback.getTalentPoolSearch(county: county, categoryId: categoryId, q: q, limit: limit, offset: offset);
    }
  }
}

