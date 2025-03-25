// lib/services/notifications_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Получение всех уведомлений пользователя
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении уведомлений: $e');
      }
      return [];
    }
  }
  
  // Получение непрочитанных уведомлений пользователя
  Future<List<Map<String, dynamic>>> getUnreadNotifications(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении непрочитанных уведомлений: $e');
      }
      return [];
    }
  }
  
  // Создание нового уведомления
  Future<String?> createNotification({
    required String userId,
    required String title,
    required String message,
    String? appointmentId,
  }) async {
    try {
      final docRef = await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'appointmentId': appointmentId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при создании уведомления: $e');
      }
      return null;
    }
  }
  
  // Отметка уведомления как прочитанного
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при отметке уведомления как прочитанного: $e');
      }
      return false;
    }
  }
  
  // Отметка всех уведомлений пользователя как прочитанных
  Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при отметке всех уведомлений как прочитанных: $e');
      }
      return false;
    }
  }
  
  // Удаление уведомления
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении уведомления: $e');
      }
      return false;
    }
  }
  
  // Удаление всех уведомлений пользователя
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении всех уведомлений: $e');
      }
      return false;
    }
  }
  
  // Создание напоминания о записи
  Future<String?> createAppointmentReminder({
    required String userId,
    required String appointmentId,
    required String serviceName,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    try {
      final String formattedDate = "${appointmentDate.day}.${appointmentDate.month}.${appointmentDate.year} в $appointmentTime";
      
      return await createNotification(
        userId: userId,
        title: 'Напоминание о записи',
        message: 'Напоминаем о вашей записи на $serviceName, $formattedDate.',
        appointmentId: appointmentId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при создании напоминания о записи: $e');
      }
      return null;
    }
  }
  
  // Получение количества непрочитанных уведомлений
  Future<int> getUnreadCount(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении количества непрочитанных уведомлений: $e');
      }
      return 0;
    }
  }
}