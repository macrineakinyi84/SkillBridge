import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    this.displayName,
    this.photoUrl,
    required this.weeklyXp,
  });

  final int rank;
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final int weeklyXp;

  @override
  List<Object?> get props => [rank, userId, displayName, photoUrl, weeklyXp];
}
