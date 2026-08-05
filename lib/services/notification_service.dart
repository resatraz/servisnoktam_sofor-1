import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Firebase Messaging
    await _firebaseMessaging.requestPermission();
    
    // Firebase token al
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Firebase Messaging handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Bildirime tıklandığında
    });
  }

  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }
}
