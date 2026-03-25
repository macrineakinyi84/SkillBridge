import '../models/employer_dashboard_model.dart';
import '../models/job_listing_model.dart';
import '../models/application_model.dart';
import '../models/candidate_model.dart';
import '../models/talent_pool_search_result.dart';

/// Employer API contract. Real impl will use ApiClient (GET/PATCH); see core/network/api_client.dart.
/// Mock impl below returns in-memory data so UI works before backend is ready.
abstract class EmployerRemoteDataSource {
  Future<EmployerDashboardModel> getDashboard(String employerId);
  Future<List<JobListingModel>> getListings(String employerId);
  Future<void> patchApplicationStatus(String applicationId, String status);
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

  Future<int> getMatchingCandidateCount(Map<String, int> skillIdToMinScore);

  Future<({List<TalentPoolSearchResult> items, int total})> getTalentPoolSearch({
    String? county,
    String? categoryId,
    String? q,
    int limit = 20,
    int offset = 0,
  });
}

class EmployerRemoteDataSourceMock implements EmployerRemoteDataSource {
  EmployerRemoteDataSourceMock() {
    _seedMockData();
  }

  final List<JobListingModel> _listings = [];
  final List<ApplicationModel> _applications = [];
  final List<CandidateModel> _candidates = [];

  void _seedMockData() {
    final now = DateTime.now();
    _listings.addAll([
      JobListingModel(
        id: 'job-1',
        title: 'Junior Flutter Developer',
        description: 'Build mobile apps with Flutter. We use Clean Architecture.',
        requiredSkillIds: ['technical-ict', 'digital-literacy'],
        county: 'Nairobi',
        type: 'Full-time',
        deadline: now.add(const Duration(days: 14)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      JobListingModel(
        id: 'job-2',
        title: 'Communications Intern',
        description: 'Support content and social media.',
        requiredSkillIds: ['communication', 'digital-literacy'],
        county: 'Mombasa',
        type: 'Internship',
        deadline: now.add(const Duration(days: 7)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
    _applications.addAll([
      ApplicationModel(
        id: 'app-1',
        jobId: 'job-1',
        candidateId: 'stu-1',
        candidateName: 'Jane Doe',
        candidateEmail: 'jane@example.com',
        status: 'pending',
        skillMatchPercent: 78,
        appliedAt: now.subtract(const Duration(days: 1)),
      ),
      ApplicationModel(
        id: 'app-2',
        jobId: 'job-1',
        candidateId: 'stu-2',
        candidateName: 'John Smith',
        candidateEmail: 'john@example.com',
        status: 'shortlisted',
        skillMatchPercent: 65,
        appliedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
    _candidates.addAll([
      CandidateModel(
        id: 'stu-1',
        applicationId: 'app-1',
        displayName: 'Jane Doe',
        email: 'jane@example.com',
        skillMatchPercent: 78,
        categoryScores: {
          'digital-literacy': 85,
          'communication': 70,
          'business-entrepreneurship': 50,
          'technical-ict': 88,
          'soft-skills-leadership': 75,
        },
        portfolioSummary: '2 projects, 1 certification. Flutter & Dart focus.',
        status: 'pending',
      ),
      CandidateModel(
        id: 'stu-2',
        applicationId: 'app-2',
        displayName: 'John Smith',
        email: 'john@example.com',
        skillMatchPercent: 65,
        categoryScores: {
          'digital-literacy': 72,
          'communication': 80,
          'business-entrepreneurship': 55,
          'technical-ict': 60,
          'soft-skills-leadership': 58,
        },
        portfolioSummary: '1 project. Strong communication.',
        status: 'shortlisted',
      ),
    ]);
  }

  @override
  Future<EmployerDashboardModel> getDashboard(String employerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final activeCount = _listings.where((l) => l.isActive).length;
    final totalApplicants = _applications.length;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final newThisWeek = _applications.where((a) => (a.appliedAt ?? DateTime(0)).isAfter(weekAgo)).length;
    final pendingCount = _applications.where((a) => a.status == 'pending').length;
    final avgMatch = _applications.isEmpty
        ? 0.0
        : _applications.map((a) => a.skillMatchPercent ?? 0).reduce((a, b) => a + b) / _applications.length;
    final ordered = _applications.orderByApplied().take(5);
    final recentApplicants = ordered.map((a) {
      final idx = _listings.indexWhere((l) => l.id == a.jobId);
      final job = idx >= 0 ? _listings[idx] : null;
      return RecentApplicantItem(
        applicationId: a.id,
        jobId: a.jobId,
        jobTitle: job?.title ?? 'Job',
        candidateName: a.candidateName ?? 'Applicant',
        skillMatchPercent: a.skillMatchPercent,
      );
    }).toList();
    String? notification;
    if (pendingCount > 0 && _listings.isNotEmpty) {
      final job = _listings.first;
      notification = '$pendingCount new match${pendingCount == 1 ? '' : 'es'} for your ${job.title} listing';
    }
    return EmployerDashboardModel(
      activeListingsCount: activeCount,
      totalApplicantsCount: totalApplicants,
      newApplicantsThisWeek: newThisWeek,
      avgMatchScore: avgMatch.roundToDouble(),
      recentApplicants: recentApplicants,
      newMatchesNotification: notification,
    );
  }

  @override
  Future<List<JobListingModel>> getListings(String employerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_listings);
  }

  @override
  Future<void> patchApplicationStatus(String applicationId, String status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final i = _applications.indexWhere((a) => a.id == applicationId);
    if (i >= 0) {
      _applications[i] = ApplicationModel(
        id: _applications[i].id,
        jobId: _applications[i].jobId,
        candidateId: _applications[i].candidateId,
        candidateName: _applications[i].candidateName,
        candidateEmail: _applications[i].candidateEmail,
        status: status,
        skillMatchPercent: _applications[i].skillMatchPercent,
        appliedAt: _applications[i].appliedAt,
      );
    }
  }

  @override
  Future<List<CandidateModel>> getCandidatesByJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final appIds = _applications.where((a) => a.jobId == jobId).map((a) => a.id).toSet();
    return _candidates.where((c) => appIds.contains(c.applicationId)).toList();
  }

  @override
  Future<CandidateModel?> getCandidateByApplicationId(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    String? appStatus;
    for (final a in _applications) {
      if (a.id == applicationId) {
        appStatus = a.status;
        break;
      }
    }
    try {
      final c = _candidates.firstWhere((c) => c.applicationId == applicationId);
      return CandidateModel(
        id: c.id,
        applicationId: c.applicationId,
        displayName: c.displayName,
        email: c.email,
        skillMatchPercent: c.skillMatchPercent,
        categoryScores: c.categoryScores,
        portfolioSummary: c.portfolioSummary,
        status: appStatus ?? c.status,
      );
    } catch (_) {
      return null;
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
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    if (listingId != null && listingId.isNotEmpty) {
      final i = _listings.indexWhere((l) => l.id == listingId);
      if (i >= 0) {
        _listings[i] = JobListingModel(
          id: _listings[i].id,
          title: title,
          description: description,
          requiredSkillIds: requiredSkillIds,
          county: county,
          type: type,
          deadline: deadline,
          isActive: _listings[i].isActive,
          createdAt: _listings[i].createdAt,
        );
        return _listings[i];
      }
    }
    final id = 'job-${DateTime.now().millisecondsSinceEpoch}';
    final listing = JobListingModel(
      id: id,
      title: title,
      description: description,
      requiredSkillIds: requiredSkillIds,
      county: county,
      type: type,
      deadline: deadline,
      isActive: true,
      createdAt: now,
    );
    _listings.insert(0, listing);
    return listing;
  }

  @override
  Future<int> getMatchingCandidateCount(Map<String, int> skillIdToMinScore) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (skillIdToMinScore.isEmpty) return 0;
    int count = 0;
    for (final c in _candidates) {
      bool matches = true;
      for (final e in skillIdToMinScore.entries) {
        final score = c.categoryScores[e.key] ?? 0;
        if (score < e.value) {
          matches = false;
          break;
        }
      }
      if (matches) count++;
    }
    return count;
  }

  @override
  Future<({List<TalentPoolSearchResult> items, int total})> getTalentPoolSearch({
    String? county,
    String? categoryId,
    String? q,
    int limit = 20,
    int offset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var items = _candidates.map((c) => TalentPoolSearchResult(
      id: c.id,
      displayName: c.displayName,
      county: null,
      photoUrl: null,
      level: 2,
      levelName: 'Rising Star',
      totalXp: 120,
    )).toList();
    if (county != null && county.isNotEmpty) {
      items = items.where((e) => e.county == county).toList();
    }
    if (q != null && q.isNotEmpty) {
      final lower = q.toLowerCase();
      items = items.where((e) => (e.displayName ?? '').toLowerCase().contains(lower)).toList();
    }
    final total = items.length;
    items = items.skip(offset).take(limit).toList();
    return (items: items, total: total);
  }
}

extension _OrderApplications on List<ApplicationModel> {
  List<ApplicationModel> orderByApplied() {
    final list = List<ApplicationModel>.from(this);
    list.sort((a, b) {
      final at = a.appliedAt ?? DateTime(0);
      final bt = b.appliedAt ?? DateTime(0);
      return bt.compareTo(at);
    });
    return list;
  }
}
