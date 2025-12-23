import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIbow554DvXg3EplaU_eUnWM99Dn_fKBM',
    appId: '1:499179561944:web:e20fb4d7f8b34f857f88ad',
    messagingSenderId: '499179561944',
    projectId: 'brandly-56d11',
    authDomain: 'brandly-56d11.firebaseapp.com',
    storageBucket: 'brandly-56d11.firebasestorage.app',
    measurementId: 'G-1YZB17Y9TG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtN57G8WSoQKi_-dafz2ihzqOZuedMRqI',
    appId: '1:499179561944:android:4bff41b54fb9aa347f88ad',
    messagingSenderId: '499179561944',
    projectId: 'brandly-56d11',
    storageBucket: 'brandly-56d11.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9lrY-tEHru9Cpgg9EhoUhL-7G1oligh8',
    appId: '1:499179561944:ios:05dd037347ea2c257f88ad',
    messagingSenderId: '499179561944',
    projectId: 'brandly-56d11',
    storageBucket: 'brandly-56d11.firebasestorage.app',
    iosBundleId: 'com.example.brandly4',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB9lrY-tEHru9Cpgg9EhoUhL-7G1oligh8',
    appId: '1:499179561944:ios:05dd037347ea2c257f88ad',
    messagingSenderId: '499179561944',
    projectId: 'brandly-56d11',
    storageBucket: 'brandly-56d11.firebasestorage.app',
    iosBundleId: 'com.example.brandly4',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAIbow554DvXg3EplaU_eUnWM99Dn_fKBM',
    appId: '1:499179561944:web:5ac676381b7d863b7f88ad',
    messagingSenderId: '499179561944',
    projectId: 'brandly-56d11',
    authDomain: 'brandly-56d11.firebaseapp.com',
    storageBucket: 'brandly-56d11.firebasestorage.app',
    measurementId: 'G-CFZW3CKTJT',
  );
}
