import 'package:votera_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.token,
    required super.isNewUser,
    required super.isProfileComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['userId'] as num).toInt(),
      token: json['token'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      isProfileComplete: json['isProfileComplete'] as bool? ?? true,
    );
  }
}
