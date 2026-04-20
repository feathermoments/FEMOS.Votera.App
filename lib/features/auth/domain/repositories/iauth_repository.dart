import 'package:votera_app/features/auth/domain/entities/user_entity.dart';

abstract interface class IAuthRepository {
  /// Returns `isExistingUser` flag.
  Future<bool> sendOtp({
    required String identifier,
    required String type,
    String? countryCode,
  });

  /// Returns [UserEntity] on success.
  Future<UserEntity> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  });

  Future<void> logout();
}
