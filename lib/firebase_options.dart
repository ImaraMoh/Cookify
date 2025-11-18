import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } /*else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return macos;
    }*/
    throw UnsupportedError('Unsupported platform');
  }

  /*static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-apiKey',
    appId: 'your-web-appId',
    messagingSenderId: 'your-web-messagingSenderId',
    projectId: 'your-web-projectId',
    storageBucket: 'your-web-storageBucket',
  );*/

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9qvGCFoWm5gEZOggzvVfJ-yW2NrHYbnk',
    appId: '1:822552724386:android:6107141d07c9305839e8fb',
    messagingSenderId: '822552724386',
    projectId: 'cookify-33c8c',
    storageBucket: 'cookify-33c8c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAg24pZs2RzP8kK-RkDFfZKw2am6o03u4',
    appId: '1:822552724386:ios:9635a2bb9621850339e8fb',
    messagingSenderId: '822552724386',
    projectId: 'cookify-33c8c',
    storageBucket: 'cookify-33c8c.firebasestorage.app',
    iosBundleId: 'com.example.mobileApp',  // Make sure to include the iOS bundle ID
  );
/*
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-apiKey',
    appId: 'your-macos-appId',
    messagingSenderId: 'your-macos-messagingSenderId',
    projectId: 'your-macos-projectId',
    storageBucket: 'your-macos-storageBucket',
    iosBundleId: 'your-macos-bundle-id',
  );*/
}