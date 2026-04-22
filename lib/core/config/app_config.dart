/// App-wide configuration constants.
abstract final class AppConfig {
  static const appName = 'Votera';
  static const tagline = 'Every Voice Matters';
  static const company = 'Feather Moments';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    //defaultValue: 'http://localhost:2043/api',
    defaultValue: 'https://voteraapi.feathermoments.com/api',
    //defaultValue: 'http://localhost:5114/api',
  );

  static const splashDuration = Duration(milliseconds: 3000);
  static const toastDuration = Duration(milliseconds: 2500);

  static const iosBundleId = 'com.feathermoments.votera';
  static const androidPackage = 'com.feathermoments.votera';
  static const firebaseVapidKey = String.fromEnvironment(
    'FIREBASE_VAPID_KEY',
    defaultValue:
        'BIZXIfiz9dFiYYyNcqFwcOcyvUQATflMmfH1XPFovTYwx7xY9YrIljZ9LTPmY8SfJ5xkV7UbdWrYzbwbaPYxq4g',
  );
}
