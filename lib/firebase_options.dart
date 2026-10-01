import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAnCy96KVZUxabtC1hg4SI8AqAW5V8uWKA',
    appId: '1:976296748562:web:348aa05d2f5302c49b1acb',
    messagingSenderId: '976296748562',
    projectId: 'mg-e8e99',
    authDomain: 'mg-e8e99.firebaseapp.com',
    storageBucket: 'mg-e8e99.firebasestorage.app',
    measurementId: 'G-D4PYFPNZTJ',
  );
}
