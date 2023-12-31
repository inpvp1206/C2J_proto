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
    apiKey: 'AIzaSyD6S0YFR66Z5Tq59buMbQ6DEAUBFQC5cv8',
    appId: '1:709714075760:web:ae7270f41af91b78b194b5',
    messagingSenderId: '709714075760',
    projectId: 'c2j-proto',
    authDomain: 'c2j-proto.firebaseapp.com',
    storageBucket: 'c2j-proto.appspot.com',
    measurementId: 'G-1R6XQXHSL2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_czkNGDD7W8qpPBq3xxO3mrIrITxYVMA',
    appId: '1:709714075760:android:332d1518d62a5671b194b5',
    messagingSenderId: '709714075760',
    projectId: 'c2j-proto',
    storageBucket: 'c2j-proto.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCM7dfEEIP46bjz0iRihaDA88eLDLAnXL0',
    appId: '1:709714075760:ios:5d72d0e7f4c32ff7b194b5',
    messagingSenderId: '709714075760',
    projectId: 'c2j-proto',
    storageBucket: 'c2j-proto.appspot.com',
    iosBundleId: 'com.example.proto',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCM7dfEEIP46bjz0iRihaDA88eLDLAnXL0',
    appId: '1:709714075760:ios:5d72d0e7f4c32ff7b194b5',
    messagingSenderId: '709714075760',
    projectId: 'c2j-proto',
    storageBucket: 'c2j-proto.appspot.com',
    iosBundleId: 'com.example.proto',
  );
}
