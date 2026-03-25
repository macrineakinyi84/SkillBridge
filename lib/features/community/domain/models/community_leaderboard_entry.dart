import 'package:equatable/equatable.dart';

class CommunityLeaderboardEntry extends Equatable {
  const CommunityLeaderboardEntry({
    required this.rank,
    required this.userId,
    this.displayName,
    this.photoUrl,
    required this.weeklyXp,
    this.level = 1,
    this.levelName = 'Starter',
  });

  final int rank;
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final int weeklyXp;
  final int level;
  final String levelName;

  @override
  List<Object?> get props => [rank, userId, displayName, photoUrl, weeklyXp, level, levelName];
}
