import 'package:equatable/equatable.dart';

enum NotificationType {
  jobMatch,
  applicationStatus,
  badgeEarned,
  levelUp,
  streakWarning,
  microLesson,
  weeklySummary,
  jobsDigest,
  reengagement,
  profileIncomplete,
  learningReminder,
  generic,
}

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.data = const {},
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, String> data;

  bool get isUnread => readAt == null;

  @override
  List<Object?> get props => [id, type, title, body, createdAt, readAt, data];
}
