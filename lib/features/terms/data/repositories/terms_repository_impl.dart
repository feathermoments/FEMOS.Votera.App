import 'package:votera_app/features/terms/domain/entities/terms_entity.dart';
import 'package:votera_app/features/terms/domain/repositories/iterms_repository.dart';
import '../datasources/terms_remote_datasource.dart';

class TermsRepositoryImpl implements ITermsRepository {
  TermsRepositoryImpl(this._remote);

  final TermsRemoteDataSource _remote;

  @override
  Future<TermsEntity> getCurrent({
    required String appCode,
    required String termsType,
  }) async {
    final map = await _remote.getCurrent(
      appCode: appCode,
      termsType: termsType,
    );
    return TermsEntity(
      version: (map['version'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      isMajorUpdate: map['isMajorUpdate'] as bool? ?? false,
      effectiveFrom: (map['effectiveFrom'] ?? '').toString(),
    );
  }

  @override
  Future<Map<String, dynamic>> accept({
    required String appCode,
    required String termsType,
    required String version,
  }) async {
    final body = {
      'appCode': appCode,
      'termsType': termsType,
      'termsVersion': version,
    };
    final map = await _remote.accept(body: body);
    return map;
  }

  @override
  Future<TermsStatusEntity> status({
    required String appCode,
    required String termsType,
  }) async {
    final map = await _remote.status(appCode: appCode, termsType: termsType);
    return TermsStatusEntity(
      currentVersion: map['currentVersion']?.toString(),
      userVersion: map['userVersion']?.toString(),
      isAcceptanceRequired: map['isAcceptanceRequired'] as bool? ?? false,
    );
  }

  @override
  Future<TermsValidateEntity> validate({required String appCode}) async {
    final map = await _remote.validate(appCode: appCode);
    return TermsValidateEntity(
      isValid: map['isValid'] as bool? ?? false,
      message: map['message']?.toString(),
    );
  }
}
