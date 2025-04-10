// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? appointmentId;
  final bool read;
  final DateTime createdAt;
  final String? imageUrl;
  final String? actionType; // 'appointment', 'promo', 'loyalty', etc.
  final Map<String, dynamic>? actionData;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.appointmentId,
    required this.read,
    required this.createdAt,
    this.imageUrl,
    this.actionType,
    this.actionData,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    // Обработка времени создания
    DateTime createdTime = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdTime = data['createdAt'].toDate();
      } else if (data['createdAt'] is int) {
        createdTime = DateTime.fromMillisecondsSinceEpoch(data['createdAt']);
      }
    }

    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      appointmentId: data['appointmentId'],
      read: data['read'] ?? false,
      createdAt: createdTime,
      imageUrl: data['imageUrl'],
      actionType: data['actionType'],
      actionData: data['actionData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'appointmentId': appointmentId,
      'read': read,
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'actionType': actionType,
      'actionData': actionData,
    };
  }
}