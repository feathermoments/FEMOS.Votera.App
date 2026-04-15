import 'package:votera_app/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.notifications);

  final List<NotificationEntity> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);

  final String message;
}
