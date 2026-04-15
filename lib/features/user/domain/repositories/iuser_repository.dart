import 'package:votera_app/features/user/domain/entities/user_profile_entity.dart';

abstract interface class IUserRepository {
  Future<UserProfileEntity> getProfile();

  Future<void> updateProfile({
    String? name,
    String? email,
    String? mobileNumber,
    String? profilePicture,
  });

  Future<String> deleteAccount();
}
