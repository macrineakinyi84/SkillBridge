import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._local);

  final NotificationLocalDataSource _local;

  @override
  Future<List<NotificationItem>> getNotifications() => _local.getNotifications();

  @override
  Future<void> markAsRead(String notificationId) => _local.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead() => _local.markAllAsRead();

  @override
  Future<void> dismiss(String notificationId) => _local.dismiss(notificationId);

  @override
  Future<void> saveFcmToken(String? token) async {
    // Persist and optionally send to backend.
  }
}
