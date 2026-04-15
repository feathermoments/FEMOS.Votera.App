class UserEntity {
  const UserEntity({
    required this.userId,
    required this.token,
    required this.isNewUser,
  });

  final int userId;
  final String token;
  final bool isNewUser;
}
