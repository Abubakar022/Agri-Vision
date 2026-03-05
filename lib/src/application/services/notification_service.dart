import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// 🔥 CRITICAL FIX: Background handler MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // No need to call showLocalNotification here;
  // FCM shows it automatically if the 'notification' block is present.
}

class NotificationService extends GetxController {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    await requestPermissions();
    await initializeLocalNotifications();
    await setupFCM();
  }

  Future<void> requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings, // Added 'settings:'
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationClick(response.payload);
      },
    );

    // 🔥 CHANNEL SYNC: ID must be 'order_channel'
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_channel',
      'آرڈر نوٹیفکیشنز',
      description: 'آرڈر کی حیثیت تبدیل ہونے پر اطلاعات',
      importance: Importance.max, // MAX importance for pop-up
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> setupFCM() async {
    // Background message handler registration
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _fcm.getToken();
    if (token != null) {
      await saveTokenToServer(token);
    }

    _fcm.onTokenRefresh.listen((newToken) {
      saveTokenToServer(newToken);
    });

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground message received: ${message.notification?.title}");
      handleForegroundMessage(message);
    });

    // Background click listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(jsonEncode(message.data));
    });

    // Terminated state click listener
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationClick(jsonEncode(initialMessage.data));
    }
  }

  Future<void> saveTokenToServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      try {
        await http.post(
          Uri.parse(
            'https://agri-vision-backend-1075549714370.us-central1.run.app/save-fcm-token',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'fcmToken': token,
            'role': 'user', // Explicitly setting user role
            'deviceType': 'android', // Fixed the iOS default issue
          }),
        );
        print('✅ FCM token saved successfully');
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  void handleForegroundMessage(RemoteMessage message) {
    showLocalNotification(message);
    unreadCount.value++;
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    String title = message.notification?.title ?? 'نوٹیفکیشن';
    String body = message.notification?.body ?? '';

    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
          'order_channel', // MUST MATCH channel ID above
          'آرڈر نوٹیفکیشنز',
          channelDescription: 'آرڈر کی حیثیت تبدیل ہونے پر اطلاعات',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF02A96C),
          playSound: true,
        );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      notificationDetails: platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  void handleNotificationClick(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        if (data['type'] == 'order_status' || data['type'] == 'order_created') {
          Get.toNamed('/order-history');
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  void resetUnread() => unreadCount.value = 0;
}
