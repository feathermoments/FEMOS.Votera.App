import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiRoutes.notifications);
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e, 'Failed to fetch notifications');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _client.patch<Map<String, dynamic>>(
        ApiRoutes.markNotificationRead(notificationId),
      );
    } on DioException catch (e) {
      _throw(e, 'Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.patch<Map<String, dynamic>>(
        ApiRoutes.markAllNotificationsRead,
      );
    } on DioException catch (e) {
      _throw(e, 'Failed to mark all notifications as read');
    }
  }

  Never _throw(DioException e, String fallback) {
    final msg =
        (e.response?.data as Map?)?['message'] as String? ??
        e.message ??
        fallback;
    throw ApiException(
      message: msg,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}
