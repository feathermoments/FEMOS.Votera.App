import 'package:votera_app/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:votera_app/features/notification/data/models/notification_model.dart';
import 'package:votera_app/features/notification/domain/entities/notification_entity.dart';
import 'package:votera_app/features/notification/domain/repositories/inotification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl(this._dataSource);

  final NotificationRemoteDataSource _dataSource;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final jsonList = await _dataSource.fetchNotifications();
    return jsonList.map(NotificationModel.fromJson).toList();
  }

  @override
  Future<void> markAsRead(int notificationId) =>
      _dataSource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead() => _dataSource.markAllAsRead();
}
