import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.userProfile,
      );
      return data ?? {};
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Failed to fetch profile';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    try {
      await _client.patch<Map<String, dynamic>>(
        ApiRoutes.updateProfile,
        data: fields,
      );
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Failed to update profile';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<String> deleteAccount() async {
    try {
      final data = await _client.delete<Map<String, dynamic>>(
        ApiRoutes.deleteAccount,
      );
      return (data?['message'] as String?) ?? 'Account deleted permanently';
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Failed to delete account';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
