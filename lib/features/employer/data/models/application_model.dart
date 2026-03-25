import 'package:equatable/equatable.dart';

/// Application with status for PATCH /applications/:id/status and candidate lists.
class ApplicationModel extends Equatable {
  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.candidateId,
    this.candidateName,
    this.candidateEmail,
    this.status = 'pending',
    this.skillMatchPercent,
    this.appliedAt,
  });

  final String id;
  final String jobId;
  final String candidateId;
  final String? candidateName;
  final String? candidateEmail;
  final String status;
  final int? skillMatchPercent;
  final DateTime? appliedAt;

  @override
  List<Object?> get props => [id, jobId, candidateId, candidateName, candidateEmail, status, skillMatchPercent, appliedAt];
}
