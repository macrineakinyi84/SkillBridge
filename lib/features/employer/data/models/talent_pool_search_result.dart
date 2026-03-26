import 'package:equatable/equatable.dart';

/// One item from GET /api/employer/talent-pool (search results).
class TalentPoolSearchResult extends Equatable {
  const TalentPoolSearchResult({
    required this.id,
    this.applicationId,
    this.displayName,
    this.county,
    this.photoUrl,
    this.level,
    this.levelName,
    this.totalXp = 0,
  });

  final String id;
  /// Optional: if the candidate is coming from an application feed (mock/demo),
  /// we can route to the application-based candidate profile screen.
  final String? applicationId;
  final String? displayName;
  final String? county;
  final String? photoUrl;
  final int? level;
  final String? levelName;
  final int totalXp;

  @override
  List<Object?> get props => [id, applicationId, displayName, county, photoUrl, level, levelName, totalXp];
}
