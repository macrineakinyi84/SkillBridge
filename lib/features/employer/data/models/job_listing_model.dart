import 'package:equatable/equatable.dart';

/// Single job posting for GET /employer/listings/:employerId and PostJobScreen.
class JobListingModel extends Equatable {
  const JobListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredSkillIds,
    required this.county,
    required this.type,
    required this.deadline,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final List<String> requiredSkillIds;
  final String county;
  final String type;
  final DateTime deadline;
  final bool isActive;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, title, description, requiredSkillIds, county, type, deadline, isActive, createdAt];
}
