import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> reportWorkspace(Map<String, dynamic> body) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.reportWorkspace,
        data: body,
      );
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Report submission failed';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
