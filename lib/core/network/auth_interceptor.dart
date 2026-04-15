import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

/// Mirrors web-user apiClient interceptors:
/// - Request: attach Bearer token from secure storage
/// - Response 401: clear tokens (BLoC handles redirect)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.clearTokens();
      // AuthBloc will detect token removal and emit unauthenticated state
      // GoRouter's authGuard will redirect to /login
    }
    handler.next(err);
  }
}
