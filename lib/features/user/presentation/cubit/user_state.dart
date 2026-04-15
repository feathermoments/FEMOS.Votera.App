import 'package:votera_app/features/user/domain/entities/user_profile_entity.dart';

abstract class UserState {
  const UserState();
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserProfileLoaded extends UserState {
  const UserProfileLoaded(this.profile);

  final UserProfileEntity profile;
}

class UserUpdating extends UserState {
  const UserUpdating(this.profile);

  final UserProfileEntity profile;
}

class UserUpdated extends UserState {
  const UserUpdated(this.profile);

  final UserProfileEntity profile;
}

class UserError extends UserState {
  const UserError(this.message);

  final String message;
}
