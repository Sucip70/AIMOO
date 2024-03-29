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
    apiKey: 'AIzaSyDo4vcYKGARmsyCCeab2LCaSnxSTYCG4og',
    appId: '1:1089526833385:web:c2bd74ffabecb6dc8ed078',
    messagingSenderId: '1089526833385',
    projectId: 'newai-2cc36',
    authDomain: 'newai-2cc36.firebaseapp.com',
    storageBucket: 'newai-2cc36.appspot.com',
    measurementId: 'G-1P6ZXKFJXS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiVuxY9kO6mte_N8Uni2WAoPBxUlQF2Js',
    appId: '1:1089526833385:android:f526505182cc14998ed078',
    messagingSenderId: '1089526833385',
    projectId: 'newai-2cc36',
    storageBucket: 'newai-2cc36.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArwoRNVL__8Ci3rYxjV-jLafvO1b5hokA',
    appId: '1:1089526833385:ios:e2bec85aa48341a38ed078',
    messagingSenderId: '1089526833385',
    projectId: 'newai-2cc36',
    storageBucket: 'newai-2cc36.appspot.com',
    androidClientId: '1089526833385-3q6iegni7k9nk92c6ik7bmj78msh205u.apps.googleusercontent.com',
    iosClientId: '1089526833385-tm2ico49rosfc6uknis4ikclnq8ll662.apps.googleusercontent.com',
    iosBundleId: 'com.minimal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyArwoRNVL__8Ci3rYxjV-jLafvO1b5hokA',
    appId: '1:1089526833385:ios:e2bec85aa48341a38ed078',
    messagingSenderId: '1089526833385',
    projectId: 'newai-2cc36',
    storageBucket: 'newai-2cc36.appspot.com',
    androidClientId: '1089526833385-3q6iegni7k9nk92c6ik7bmj78msh205u.apps.googleusercontent.com',
    iosClientId: '1089526833385-tm2ico49rosfc6uknis4ikclnq8ll662.apps.googleusercontent.com',
    iosBundleId: 'com.minimal',
  );
}
