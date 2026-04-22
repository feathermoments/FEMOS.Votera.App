import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for auth tokens.
class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> setAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> setUserId(int userId) =>
      _storage.write(key: _userIdKey, value: userId.toString());

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static const _fcmTokenKey = 'fcm_token';

  Future<String?> getFcmToken() => _storage.read(key: _fcmTokenKey);

  Future<void> setFcmToken(String token) =>
      _storage.write(key: _fcmTokenKey, value: token);

  Future<void> deleteFcmToken() => _storage.delete(key: _fcmTokenKey);
}
