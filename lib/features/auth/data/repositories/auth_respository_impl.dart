import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:votera_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:votera_app/features/auth/data/models/user_model.dart';
import 'package:votera_app/features/auth/domain/entities/user_entity.dart';
import 'package:votera_app/features/auth/domain/repositories/iauth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._dataSource, this._storage);

  final AuthRemoteDataSource _dataSource;
  final SecureStorageService _storage;

  @override
  Future<bool> sendOtp({required String identifier, required String type}) {
    return _dataSource.sendOtp(identifier: identifier, type: type);
  }

  @override
  Future<UserEntity> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  }) async {
    final json = await _dataSource.verifyOtp(
      identifier: identifier,
      type: type,
      otp: otp,
    );
    final user = UserModel.fromJson(json);
    if (user.token.isNotEmpty) {
      await _storage.setAccessToken(user.token);
    }
    if (user.userId != 0) {
      await _storage.setUserId(user.userId);
    }
    return user;
  }

  @override
  Future<void> logout() => _storage.clearTokens();
}
