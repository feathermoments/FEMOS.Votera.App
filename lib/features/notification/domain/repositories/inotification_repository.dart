import 'package:votera_app/features/notification/domain/entities/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
}
