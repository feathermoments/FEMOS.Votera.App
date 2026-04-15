import 'package:votera_app/core/config/app_config.dart';
import 'package:votera_app/core/network/auth_interceptor.dart';
import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

/// Dio-based API client mirroring web-user/src/lib/api-client.ts.
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );
    _dio.interceptors.addAll([
      AuthInterceptor(_storage),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  final SecureStorageService _storage;
  late final Dio _dio;

  Dio get dio => _dio;

  Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    // legacy alias used across the codebase
    Map<String, dynamic>? queryParams,
  }) async {
    final qp = queryParameters ?? queryParams;
    final response = await _dio.get<T>(path, queryParameters: qp);
    return response.data;
  }

  Future<T?> post<T>(String path, {dynamic data}) async {
    final response = await _dio.post<T>(path, data: data);
    return response.data;
  }

  Future<T?> put<T>(String path, {dynamic data}) async {
    final response = await _dio.put<T>(path, data: data);
    return response.data;
  }

  Future<T?> delete<T>(String path, {dynamic data}) async {
    final response = await _dio.delete<T>(path, data: data);
    return response.data;
  }

  Future<T?> patch<T>(String path, {dynamic data}) async {
    final response = await _dio.patch<T>(path, data: data);
    return response.data;
  }

  Future<T?> upload<T>(
    String path,
    String filePath, {
    String field = 'file',
    Map<String, dynamic>? extraFields,
  }) async {
    final formData = FormData.fromMap({
      field: await MultipartFile.fromFile(filePath),
      ...?extraFields,
    });
    final response = await _dio.post<T>(path, data: formData);
    return response.data;
  }
}
