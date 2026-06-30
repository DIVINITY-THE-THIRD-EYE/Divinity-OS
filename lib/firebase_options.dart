import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured. Run `flutterfire configure`.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5bGoBTwdvFvR1d_nv0UeEsW7xP1d-WmE',
    appId: '1:570181543606:android:825ee98cce08e361316817',
    messagingSenderId: '570181543606',
    projectId: 'divinity-the-third-eye',
    storageBucket: 'divinity-the-third-eye.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9_MnUohwn6vFgGMiBHZ2cZ-QeRoiC4fo',
    appId: '1:570181543606:ios:fb361149975be350316817',
    messagingSenderId: '570181543606',
    projectId: 'divinity-the-third-eye',
    storageBucket: 'divinity-the-third-eye.firebasestorage.app',
    iosBundleId: 'com.divinity.divinityApp',
  );
}
