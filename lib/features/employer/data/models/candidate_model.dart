import 'package:equatable/equatable.dart';

/// Applicant with skill match for GET /employer/candidates/:jobId.
/// Category scores used for radar chart (same 5 categories as skills assessment).
class CandidateModel extends Equatable {
  const CandidateModel({
    required this.id,
    required this.applicationId,
    this.displayName,
    this.email,
    this.skillMatchPercent = 0,
    this.categoryScores = const {},
    this.portfolioSummary,
    this.status = 'pending',
  });

  final String id;
  final String applicationId;
  final String? displayName;
  final String? email;
  final int skillMatchPercent;
  /// Keys: category ids (e.g. digital-literacy, communication). Values: 0–100.
  final Map<String, int> categoryScores;
  final String? portfolioSummary;
  /// Application status for accept/reject/shortlist (pending, shortlisted, accepted, rejected).
  final String status;

  @override
  List<Object?> get props => [id, applicationId, displayName, email, skillMatchPercent, categoryScores, portfolioSummary, status];
}
