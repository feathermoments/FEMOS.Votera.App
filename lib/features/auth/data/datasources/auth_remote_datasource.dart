import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  /// Returns `isExistingUser` flag from the response.
  Future<bool> sendOtp({
    required String identifier,
    required String type,
    String? countryCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'identifier': identifier,
        'type': type,
        if (countryCode != null) 'countryCode': countryCode,
      };
      final data = await _client.post<Map<String, dynamic>>(
        ApiRoutes.sendOtp,
        data: body,
      );
      return data?['isExistingUser'] as bool? ?? false;
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Failed to send OTP';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Returns raw JSON map on successful OTP verification.
  Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  }) async {
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiRoutes.verifyOtp,
        data: {'identifier': identifier, 'type': type, 'otp': otp},
      );
      return data ?? {};
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'OTP verification failed';
      throw ApiException(
        message: msg,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
