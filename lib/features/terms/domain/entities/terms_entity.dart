class TermsEntity {
  TermsEntity({
    required this.version,
    required this.title,
    required this.content,
    required this.isMajorUpdate,
    required this.effectiveFrom,
  });

  final String version;
  final String title;
  final String content;
  final bool isMajorUpdate;
  final String effectiveFrom;
}

class TermsStatusEntity {
  TermsStatusEntity({
    required this.currentVersion,
    required this.userVersion,
    required this.isAcceptanceRequired,
  });

  final String? currentVersion;
  final String? userVersion;
  final bool isAcceptanceRequired;
}

class TermsValidateEntity {
  TermsValidateEntity({required this.isValid, this.message});
  final bool isValid;
  final String? message;
}
