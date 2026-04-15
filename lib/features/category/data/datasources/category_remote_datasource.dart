import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> fetchCategories(int workspaceId) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.pollCategories,
        queryParameters: {'workspaceId': workspaceId},
      );
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Failed to fetch categories';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
