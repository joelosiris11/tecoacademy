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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBGXXZHGQEJXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:587278135241:web:69445e578a82e20f2b8218',
    messagingSenderId: '587278135241',
    projectId: 'tecoacademy-40ade',
    authDomain: 'tecoacademy-40ade.firebaseapp.com',
    storageBucket: 'tecoacademy-40ade.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGXXZHGQEJXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:587278135241:android:3702c0028152eedc2b8218',
    messagingSenderId: '587278135241',
    projectId: 'tecoacademy-40ade',
    storageBucket: 'tecoacademy-40ade.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGXXZHGQEJXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:587278135241:ios:dddf6f981389e4452b8218',
    messagingSenderId: '587278135241',
    projectId: 'tecoacademy-40ade',
    storageBucket: 'tecoacademy-40ade.appspot.com',
    iosBundleId: 'com.teco.tecoacademy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGXXZHGQEJXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:587278135241:macos:dddf6f981389e4452b8218',
    messagingSenderId: '587278135241',
    projectId: 'tecoacademy-40ade',
    storageBucket: 'tecoacademy-40ade.appspot.com',
    iosBundleId: 'com.teco.tecoacademy',
  );
} 