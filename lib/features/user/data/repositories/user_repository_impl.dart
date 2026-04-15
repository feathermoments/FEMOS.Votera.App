import 'package:votera_app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:votera_app/features/user/data/models/user_profile_model.dart';
import 'package:votera_app/features/user/domain/entities/user_profile_entity.dart';
import 'package:votera_app/features/user/domain/repositories/iuser_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  UserRepositoryImpl(this._dataSource);

  final UserRemoteDataSource _dataSource;

  @override
  Future<UserProfileEntity> getProfile() async {
    final json = await _dataSource.fetchProfile();
    return UserProfileModel.fromJson(json);
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? email,
    String? mobileNumber,
    String? profilePicture,
  }) async {
    final fields = <String, dynamic>{};
    if (name != null) fields['name'] = name;
    if (email != null) fields['email'] = email;
    if (mobileNumber != null) fields['mobileNumber'] = mobileNumber;
    if (profilePicture != null) fields['profilePicture'] = profilePicture;
    await _dataSource.updateProfile(fields);
  }

  @override
  Future<String> deleteAccount() => _dataSource.deleteAccount();
}
