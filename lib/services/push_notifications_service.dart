import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class PushNotificationsService {
  static final local = tz.getLocation('Asia/Almaty');

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    // Add timezone initialization
    tz.initializeTimeZones();

    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await _fcm.getToken();
    
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeTokenFromDatabase(String userId) async {
    String? token = await _fcm.getToken();
    
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap based on message data
    if (message.data.containsKey('appointmentId')) {
      // Navigate to appointment details
      // You'll need to implement navigation logic here
    }
  }

  Future<void> scheduleAppointmentReminder(String userId, {
    required String appointmentId,
    required String serviceName,
    required String masterName,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    // Schedule notification 1 day before
    final scheduledTime = appointmentDate.subtract(const Duration(days: 1));
    if (scheduledTime.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        appointmentId.hashCode,
        'Напоминание о записи',
        'Завтра у вас запись на $serviceName к мастеру $masterName в $appointmentTime',
        tz.TZDateTime.from(scheduledTime, local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'appointments_channel',
            'Appointments Notifications',
            importance: Importance.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'appointment_$appointmentId',
      );
    }

    // Schedule notification 1 hour before
    final oneHourBefore = appointmentDate.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        '${appointmentId}_hour'.hashCode,
        'Скоро ваша запись',
        'Через час у вас запись на $serviceName к мастеру $masterName',
        tz.TZDateTime.from(oneHourBefore, local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'appointments_channel',
            'Appointments Notifications',
            importance: Importance.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'appointment_$appointmentId',
      );
    }
  }

  Future<void> sendAppointmentCancellationNotification(String userId, {
    required String appointmentId,
    required String serviceName,
    required String masterName,
    required DateTime appointmentDate,
    required String appointmentTime,
    String? reason,
  }) async {
    final message = reason != null
        ? 'Ваша запись на $serviceName к мастеру $masterName ($appointmentTime) отменена. Причина: $reason'
        : 'Ваша запись на $serviceName к мастеру $masterName ($appointmentTime) отменена.';

    // Cancel any scheduled reminders
    await _localNotifications.cancel(appointmentId.hashCode);
    await _localNotifications.cancel('${appointmentId}_hour'.hashCode);

    // Show immediate cancellation notification
    await _localNotifications.show(
      'cancel_$appointmentId'.hashCode,
      'Запись отменена',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'appointments_channel',
          'Appointments Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'appointment_$appointmentId',
    );

    // Also send push notification via FCM
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final tokens = List<String>.from(userDoc.data()?['fcmTokens'] ?? []);

    if (tokens.isNotEmpty) {
      await _firestore.collection('notifications_queue').add({
        'payload': {
          'notification': {
            'title': 'Запись отменена',
            'body': message,
          },
          'data': {
            'type': 'appointment_cancelled',
            'appointmentId': appointmentId,
          },
          'registration_ids': tokens,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });
    }
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to ensure Firebase is initialized
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}
