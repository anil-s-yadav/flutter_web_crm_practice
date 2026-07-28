import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// Note: Once we migrate to BLoC and have HTTP setup, we will import our ApiService here to send the token.

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted notification permission');
      }
      
      // 2. Get FCM Token
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // TODO: Send this token to Node.js backend using PUT /api/users/fcm-token
      // await ApiService.updateFcmToken(token!);

      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        // TODO: Send refreshed token to backend
        if (kDebugMode) {
          print('FCM Token Refreshed: $newToken');
        }
      });

      // 3. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }

        if (message.notification != null) {
          // Show a toast or local notification
          EasyLoading.showInfo(
            '${message.notification?.title}\n${message.notification?.body}',
            duration: const Duration(seconds: 4),
            dismissOnTap: true,
          );
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }
}

// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}
