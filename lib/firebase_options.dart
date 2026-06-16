// Run `flutterfire configure` to replace these placeholder values.
// Until configured, Firebase (FCM, Analytics, Crashlytics) is gracefully
// disabled: main.dart wraps Firebase.initializeApp in try/catch.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for '
          '${defaultTargetPlatform.name}. Run `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:web:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'divinity-placeholder',
    storageBucket: 'divinity-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:android:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'divinity-placeholder',
    storageBucket: 'divinity-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:ios:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'divinity-placeholder',
    storageBucket: 'divinity-placeholder.appspot.com',
    iosClientId: 'PLACEHOLDER.apps.googleusercontent.com',
    iosBundleId: 'com.divinity.app',
  );
}
