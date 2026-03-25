import 'package:equatable/equatable.dart';

/// One item from GET /api/employer/talent-pool (search results).
class TalentPoolSearchResult extends Equatable {
  const TalentPoolSearchResult({
    required this.id,
    this.displayName,
    this.county,
    this.photoUrl,
    this.level,
    this.levelName,
    this.totalXp = 0,
  });

  final String id;
  final String? displayName;
  final String? county;
  final String? photoUrl;
  final int? level;
  final String? levelName;
  final int totalXp;

  @override
  List<Object?> get props => [id, displayName, county, photoUrl, level, levelName, totalXp];
}
