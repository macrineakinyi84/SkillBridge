import 'package:equatable/equatable.dart';

/// One row for "recent applicants" on dashboard: link to candidate and job.
class RecentApplicantItem extends Equatable {
  const RecentApplicantItem({
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.candidateName,
    this.skillMatchPercent,
  });

  final String applicationId;
  final String jobId;
  final String jobTitle;
  final String candidateName;
  final int? skillMatchPercent;

  @override
  List<Object?> get props => [applicationId, jobId, jobTitle, candidateName, skillMatchPercent];
}

/// Response shape for GET /employer/dashboard/:employerId.
/// Stats: active jobs, total applicants, new this week, avg match; recent applicants; notification.
class EmployerDashboardModel extends Equatable {
  const EmployerDashboardModel({
    required this.activeListingsCount,
    required this.totalApplicantsCount,
    required this.newApplicantsThisWeek,
    required this.avgMatchScore,
    this.recentApplicants = const [],
    this.newMatchesNotification,
  });

  factory EmployerDashboardModel.fromJson(Map<String, dynamic> json) {
    final recent = (json['recentApplicants'] as List?)
            ?.cast<Map>()
            .map((m) => m.cast<String, dynamic>())
            .map(
              (m) => RecentApplicantItem(
                applicationId: (m['applicationId'] as String?) ?? '',
                jobId: (m['jobId'] as String?) ?? '',
                jobTitle: (m['jobTitle'] as String?) ?? 'Job',
                candidateName: (m['candidateName'] as String?) ?? 'Applicant',
                skillMatchPercent: (m['skillMatchPercent'] as num?)?.toInt(),
              ),
            )
            .where((e) => e.applicationId.isNotEmpty)
            .toList() ??
        const <RecentApplicantItem>[];

    return EmployerDashboardModel(
      activeListingsCount: (json['activeListingsCount'] as num?)?.toInt() ?? 0,
      totalApplicantsCount: (json['totalApplicantsCount'] as num?)?.toInt() ?? 0,
      newApplicantsThisWeek: (json['newApplicantsThisWeek'] as num?)?.toInt() ?? 0,
      avgMatchScore: (json['avgMatchScore'] as num?)?.toDouble() ?? 0.0,
      recentApplicants: recent,
      newMatchesNotification: json['newMatchesNotification'] as String?,
    );
  }

  final int activeListingsCount;
  final int totalApplicantsCount;
  final int newApplicantsThisWeek;
  final double avgMatchScore;
  final List<RecentApplicantItem> recentApplicants;
  /// e.g. "3 new matches for your Junior Flutter Developer listing"
  final String? newMatchesNotification;

  @override
  List<Object?> get props => [activeListingsCount, totalApplicantsCount, newApplicantsThisWeek, avgMatchScore, recentApplicants, newMatchesNotification];
}
