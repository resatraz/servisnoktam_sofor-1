import 'package:firebase_messaging/firebase_messaging.dart';

// Top-level background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message received
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Firebase Messaging
    await _firebaseMessaging.requestPermission();
    
    // Firebase token al
    await _firebaseMessaging.getToken();

    // Firebase Messaging handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Message received
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Bildirime tıklandığında
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }
}
