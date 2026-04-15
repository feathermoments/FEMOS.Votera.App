import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/user/domain/entities/user_profile_entity.dart';
import 'package:votera_app/features/user/domain/repositories/iuser_repository.dart';
import 'package:votera_app/features/user/presentation/cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserInitial()) {
    _repository = sl<IUserRepository>();
  }

  late final IUserRepository _repository;

  Future<void> loadProfile() async {
    emit(const UserLoading());
    try {
      final profile = await _repository.getProfile();
      emit(UserProfileLoaded(profile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? mobileNumber,
    String? profilePicture,
  }) async {
    final current = state;
    if (current is! UserProfileLoaded) return;
    emit(UserUpdating(current.profile));
    try {
      await _repository.updateProfile(
        name: name,
        email: email,
        mobileNumber: mobileNumber,
        profilePicture: profilePicture,
      );
      // Reload to get updated data
      final updated = await _repository.getProfile();
      emit(UserUpdated(updated));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  UserProfileEntity? get currentProfile {
    final s = state;
    if (s is UserProfileLoaded) return s.profile;
    if (s is UserUpdating) return s.profile;
    if (s is UserUpdated) return s.profile;
    return null;
  }
}
