import 'package:firebase_core/firebase_core.dart';

/// Manually-provided FirebaseOptions for web initialization.
/// Values should match `web/firebase-config.js`.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get web => const FirebaseOptions(
    apiKey: 'AIzaSyC1HLkWJh7bZYk6GU_RgqCwfbldlnS9IOg',
    authDomain: 'votera-6ffda.firebaseapp.com',
    projectId: 'votera-6ffda',
    storageBucket: 'votera-6ffda.firebasestorage.app',
    messagingSenderId: '105535083242',
    appId: '1:105535083242:web:00000000000000',
  );
}
