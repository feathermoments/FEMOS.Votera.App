import '../entities/terms_entity.dart';

abstract interface class ITermsRepository {
  Future<TermsValidateEntity> validate({required String appCode});
  Future<TermsEntity> getCurrent({
    required String appCode,
    required String termsType,
  });

  /// Returns raw response map from the accept API (eg. {success,message}).
  Future<Map<String, dynamic>> accept({
    required String appCode,
    required String termsType,
    required String version,
  });
  Future<TermsStatusEntity> status({
    required String appCode,
    required String termsType,
  });
}
