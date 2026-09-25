import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions Tests', () {
    test('android options contain correct projectId, appId and storageBucket',
        () {
      const android = DefaultFirebaseOptions.android;
      expect(android.projectId, 'zworkflow-zaramell');
      expect(android.appId, '1:390851858388:android:822f2d162727824a7a5041');
      expect(android.apiKey, isNotEmpty);
      expect(android.messagingSenderId, '390851858388');
      expect(android.storageBucket, 'zworkflow-zaramell.firebasestorage.app');
    });

    test('ios options contain correct projectId, appId and bundleId', () {
      const ios = DefaultFirebaseOptions.ios;
      expect(ios.projectId, 'zworkflow-zaramell');
      expect(ios.appId, '1:390851858388:ios:d0eb9eb4ef28a9407a5041');
      expect(ios.apiKey, isNotEmpty);
      expect(ios.messagingSenderId, '390851858388');
      expect(ios.storageBucket, 'zworkflow-zaramell.firebasestorage.app');
      expect(ios.iosBundleId, 'com.zaramella.zworkflow');
    });

    test('web options contain correct projectId, appId and authDomain', () {
      const web = DefaultFirebaseOptions.web;
      expect(web.projectId, 'zworkflow-zaramell');
      expect(web.appId, '1:390851858388:web:822f2d162727824a7a5041');
      expect(web.apiKey, isNotEmpty);
      expect(web.messagingSenderId, '390851858388');
      expect(web.authDomain, 'zworkflow-zaramell.firebaseapp.com');
      expect(web.storageBucket, 'zworkflow-zaramell.firebasestorage.app');
    });
  });
}
