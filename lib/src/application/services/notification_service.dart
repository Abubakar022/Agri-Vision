import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> initializeLocalNotifications() async {
    // Android settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();
    
    // Combine both settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // FIX 1: Initialize with CORRECT parameter name 'settings'
    await _localNotifications.initialize(
      settings: initSettings,  // ← CORRECT: 'settings' is the parameter name
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationClick(response.payload);
      },
    );

    // Create notification channel for Android
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_channel', // id
      'آرڈر نوٹیفکیشنز', // name
      description: 'آرڈر کی حیثیت تبدیل ہونے پر اطلاعات',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> setupFCM() async {
    // Get FCM token
    String? token = await _fcm.getToken();
    if (token != null) {
      await saveTokenToServer(token);
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      saveTokenToServer(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleForegroundMessage(message);
    });

    // Handle when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(jsonEncode(message.data));
    });

    // Handle when app is opened from terminated state
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
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/save-fcm-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'fcmToken': token,
          }),
        );
        
        if (response.statusCode == 200) {
          print('✅ FCM token saved successfully');
        }
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  void handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    showLocalNotification(message);
    
    // Increment unread count
    unreadCount.value++;
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    String title = message.notification?.title ?? 'نوٹیفکیشن';
    String body = message.notification?.body ?? '';
    
    // Android notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'order_channel',
      'آرڈر نوٹیفکیشنز',
      channelDescription: 'آرڈر کی حیثیت تبدیل ہونے پر اطلاعات',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF02A96C),
      playSound: true,
      enableVibration: true,
    );

    // iOS notification details
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    // Combine both platforms
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate unique ID for notification
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // FIX 2: Show notification with CORRECT parameter names
   // Locate this section in your showLocalNotification method
await _localNotifications.show(
  id: notificationId,                 // Add 'id:'
  title: title,                        // Add 'title:'
  body: body,                          // Add 'body:'
  notificationDetails: platformDetails, // Add 'notificationDetails:'
  payload: jsonEncode(message.data),   // This one was already named, keep it
);
  }

  void handleNotificationClick(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        if (data['type'] == 'order_status' || data['type'] == 'order_created') {
          // Navigate to order history
          Get.toNamed('/order-history');
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> removeTokenFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = await _fcm.getToken();
    
    if (userId != null && token != null) {
      try {
        await http.post(
          Uri.parse('http://10.0.2.2:5000/remove-fcm-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'fcmToken': token,
          }),
        );
        print('✅ FCM token removed successfully');
      } catch (e) {
        print('Error removing token: $e');
      }
    }
  }

  void decrementUnread() {
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }

  void resetUnread() {
    unreadCount.value = 0;
  }
}