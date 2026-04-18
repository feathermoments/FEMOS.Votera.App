class UserEntity {
  const UserEntity({
    required this.userId,
    required this.token,
    required this.isNewUser,
    required this.isProfileComplete,
  });

  final int userId;
  final String token;
  final bool isNewUser;
  final bool isProfileComplete;
}
