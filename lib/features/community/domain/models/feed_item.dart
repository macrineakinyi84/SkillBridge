import 'package:equatable/equatable.dart';

/// Activity type for feed item display (icon mapping).
enum FeedActivityType {
  assessment,
  job,
  badge,
  level,
}

class FeedItem extends Equatable {
  const FeedItem({
    required this.id,
    required this.type,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.message,
    required this.createdAt,
    this.metadata,
  });

  final String id;
  final FeedActivityType type;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [id, type, userId, displayName, photoUrl, message, createdAt, metadata];
}
