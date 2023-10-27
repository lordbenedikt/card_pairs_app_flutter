// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyBcygx1W39RLi5k8nngv9r5aUtPG5JLCvg',
    appId: '1:206763302427:web:1a0d510004106f89eaa2be',
    messagingSenderId: '206763302427',
    projectId: 'memory-app-a167e',
    authDomain: 'memory-app-a167e.firebaseapp.com',
    storageBucket: 'memory-app-a167e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCe1-pZlPIOCY1H6iz6mjz9t_PI1BLWTM0',
    appId: '1:206763302427:android:9ab4801098031f2feaa2be',
    messagingSenderId: '206763302427',
    projectId: 'memory-app-a167e',
    storageBucket: 'memory-app-a167e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCABmnIGn2uAqIpMRJCPXVTMYGNnV3ekWY',
    appId: '1:206763302427:ios:e0efe7eeff1a25fdeaa2be',
    messagingSenderId: '206763302427',
    projectId: 'memory-app-a167e',
    storageBucket: 'memory-app-a167e.appspot.com',
    iosBundleId: 'com.example.memory',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCABmnIGn2uAqIpMRJCPXVTMYGNnV3ekWY',
    appId: '1:206763302427:ios:4c4cda7e2196fa91eaa2be',
    messagingSenderId: '206763302427',
    projectId: 'memory-app-a167e',
    storageBucket: 'memory-app-a167e.appspot.com',
    iosBundleId: 'com.example.memory.RunnerTests',
  );
}
