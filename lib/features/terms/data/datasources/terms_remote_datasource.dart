import 'package:dio/dio.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_exception.dart';

class TermsRemoteDataSource {
  TermsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getCurrent({
    required String appCode,
    required String termsType,
  }) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.termsCurrent,
        queryParameters: {'appCode': appCode, 'termsType': termsType},
      );
      return data ?? {};
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Terms request failed';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<Map<String, dynamic>> status({
    required String appCode,
    required String termsType,
  }) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.termsStatus,
        queryParameters: {'appCode': appCode, 'termsType': termsType},
      );
      return data ?? {};
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.error?.toString() ??
          e.response?.statusMessage ??
          'Terms request failed';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<Map<String, dynamic>> validate({required String appCode}) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.termsValidate,
        queryParameters: {'appCode': appCode},
      );
      return data ?? {};
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.error?.toString() ??
          e.response?.statusMessage ??
          'Terms request failed';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<Map<String, dynamic>> accept({
    required Map<String, dynamic> body,
  }) async {
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiRoutes.termsAccept,
        data: body,
      );
      return data ?? {};
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.error?.toString() ??
          e.response?.statusMessage ??
          'Terms request failed';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
