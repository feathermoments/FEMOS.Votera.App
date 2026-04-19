class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.navigationLink,
  });

  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final String navigationLink;
}
