import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

/// Local/mock store for notifications. Replace with API + FCM.
abstract class NotificationLocalDataSource {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> dismiss(String notificationId);
}

class NotificationLocalDataSourceMock implements NotificationLocalDataSource {
  final List<NotificationItem> _items = [];
  bool _seeded = false;

  void _seed() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    _items.addAll([
      NotificationItem(
        id: 'n1',
        type: NotificationType.jobMatch,
        title: 'New job match',
        body: 'Junior Developer at Tech Co is 85% match for you.',
        createdAt: now.subtract(const Duration(hours: 2)),
        data: {'jobId': 'j1', 'matchScore': '85'},
      ),
      NotificationItem(
        id: 'n2',
        type: NotificationType.badgeEarned,
        title: 'Badge earned',
        body: 'You earned the "First Assessment" badge!',
        createdAt: now.subtract(const Duration(days: 1)),
        data: {'badgeName': 'First Assessment'},
      ),
      NotificationItem(
        id: 'n3',
        type: NotificationType.applicationStatus,
        title: 'Application update',
        body: 'Your application for "Mobile Dev Intern" is now Under review.',
        createdAt: now.subtract(const Duration(days: 3)),
        readAt: now.subtract(const Duration(days: 2)),
        data: {'jobId': 'j2', 'newStatus': 'under_review'},
      ),
      NotificationItem(
        id: 'n4',
        type: NotificationType.learningReminder,
        title: 'Learning reminder',
        body: 'You have 2 micro-lessons waiting. Spend 5 minutes to keep your streak.',
        createdAt: now.subtract(const Duration(days: 1)),
        data: const {},
      ),
      NotificationItem(
        id: 'n5',
        type: NotificationType.levelUp,
        title: 'Level up!',
        body: 'You reached Level 2 • Rising Star. Keep going!',
        createdAt: now.subtract(const Duration(days: 5)),
        readAt: now.subtract(const Duration(days: 4)),
        data: const {'newLevel': '2'},
      ),
    ]);
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _seed();
    final list = List<NotificationItem>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _items.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) {
      _items[idx] = NotificationItem(
        id: _items[idx].id,
        type: _items[idx].type,
        title: _items[idx].title,
        body: _items[idx].body,
        createdAt: _items[idx].createdAt,
        readAt: DateTime.now(),
        data: _items[idx].data,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 80));
    final now = DateTime.now();
    for (var i = 0; i < _items.length; i++) {
      final n = _items[i];
      if (n.readAt == null) {
        _items[i] = NotificationItem(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          createdAt: n.createdAt,
          readAt: now,
          data: n.data,
        );
      }
    }
  }

  @override
  Future<void> dismiss(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _items.removeWhere((n) => n.id == notificationId);
  }
}
