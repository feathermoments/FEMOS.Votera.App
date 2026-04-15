import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> fetchActivePolls() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiRoutes.activePolls);
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.dashboardStats,
      );
      return data ?? {};
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Never _throw(DioException e) {
    final msg =
        (e.response?.data as Map?)?['message'] as String? ??
        e.message ??
        'Dashboard request failed';
    throw ApiException(
      message: msg,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}
