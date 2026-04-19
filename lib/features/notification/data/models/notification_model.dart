import 'package:votera_app/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.isRead,
    required super.createdAt,
    required super.navigationLink,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) => NotificationModel(
    id: ((json['id'] ?? json['notificationId']) as num).toInt(),
    title:
        (json['title'] as String?) ??
        (json['notificationTitle'] as String?) ??
        '',
    message:
        (json['message'] as String?) ??
        (json['notificationMessage'] as String?) ??
        '',
    isRead: (json['isRead'] as bool?) ?? (json['is_read'] as bool?) ?? false,
    createdAt:
        (json['createdAt'] as String?) ?? (json['receivedOn'] as String?) ?? '',
    navigationLink:
        (json['navigationLink'] as String?) ??
        (json['navigation_link'] as String?) ??
        (json['navigation'] as String?) ??
        (json['link'] as String?) ??
        '',
  );
}
