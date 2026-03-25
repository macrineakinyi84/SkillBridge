import 'package:equatable/equatable.dart';

enum ChallengeStatus { pending, active, completed, expired }

class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.expiresAt,
    this.acceptedAt,
    this.fromScore,
    this.toScore,
    this.winnerUserId,
    this.xpAwarded,
    this.fromDisplayName,
    this.toDisplayName,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final String categoryId;
  final String categoryName;
  final ChallengeStatus status;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final int? fromScore;
  final int? toScore;
  final String? winnerUserId;
  /// XP awarded to current user when completed (if viewing as participant).
  final int? xpAwarded;
  final String? fromDisplayName;
  final String? toDisplayName;

  bool get isPending => status == ChallengeStatus.pending;
  bool get isActive => status == ChallengeStatus.active;
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isExpired => status == ChallengeStatus.expired;

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        categoryId,
        categoryName,
        status,
        expiresAt,
        acceptedAt,
        fromScore,
        toScore,
        winnerUserId,
        xpAwarded,
        fromDisplayName,
        toDisplayName,
      ];
}
