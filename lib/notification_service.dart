import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_assignment_8/firebase_options.dart';
import 'package:flutter_assignment_8/notification_detail_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Pesan BACKGROUND: ${message.messageId}');
  debugPrint('[FCM] Data: ${message.data}');
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifikasi Penting',
    description: 'Channel untuk notifikasi dari Firebase Cloud Messaging',
    importance: Importance.max,
  );

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Status izin: ${settings.authorizationStatus}');

    if (!kIsWeb) {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _localNotif.initialize(
        settings: const InitializationSettings(android: androidInit),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            _openDetail(jsonDecode(response.payload!) as Map<String, dynamic>);
          }
        },
      );

      await _localNotif
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      await _messaging.subscribeToTopic('kelas');
    }

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Dibuka dari BACKGROUND');
      _openDetail(_messageToMap(message));
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] Dibuka dari kondisi MATI (terminated)');
      _openDetail(_messageToMap(initialMessage));
    }

    if (!kIsWeb) {
      final launchDetails = await _localNotif.getNotificationAppLaunchDetails();
      final payload = launchDetails?.notificationResponse?.payload;
      if ((launchDetails?.didNotificationLaunchApp ?? false) && payload != null) {
        _openDetail(jsonDecode(payload) as Map<String, dynamic>);
      }
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    debugPrint('[FCM] Pesan FOREGROUND: ${message.notification?.title}');
    debugPrint('[FCM] Data FOREGROUND: ${message.data}');

    final notification = message.notification;
    if (notification == null) return;

    if (!kIsWeb) {
      await _localNotif.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(_messageToMap(message)),
      );
    } else {
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              '${notification.title ?? 'Notifikasi'}: ${notification.body ?? ''}',
            ),
            action: SnackBarAction(
              label: 'Detail',
              onPressed: () => _openDetail(_messageToMap(message)),
            ),
          ),
        );
      }
    }
  }

  static Map<String, dynamic> _messageToMap(RemoteMessage message) {
    return {
      'title': message.notification?.title ?? '-',
      'body': message.notification?.body ?? '-',
      ...message.data,
    };
  }

  static void _openDetail(Map<String, dynamic> data) {
    void push() {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NotificationDetailScreen(data: data),
        ),
      );
    }

    if (navigatorKey.currentState != null) {
      push();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => push());
    }
  }
}