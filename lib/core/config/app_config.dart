/// App-wide configuration constants.
abstract final class AppConfig {
  static const appName = 'Votera';
  static const tagline = 'Every Voice Matters';
  static const company = 'Feather Moments';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:2043/api',
  );

  static const maxFamilyMembers = 5;
  static const maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const allowedReportTypes = ['pdf', 'jpeg', 'jpg', 'png'];

  static const splashDuration = Duration(milliseconds: 3500);
  static const toastDuration = Duration(milliseconds: 2500);

  static const iosBundleId = 'com.feathermoments.votera';
  static const androidPackage = 'com.feathermoments.votera';
}
