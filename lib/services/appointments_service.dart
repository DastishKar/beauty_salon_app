// lib/services/appointments_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/appointment_model.dart';
import 'services_service.dart';
import 'masters_service.dart';

class AppointmentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServicesService _servicesService = ServicesService();
  final MastersService _mastersService = MastersService();
  
  // Получение всех записей пользователя
  Future<List<AppointmentModel>> getUserAppointments(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('clientId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .orderBy('startTime')
          .get();
      
      final List<AppointmentModel> appointments = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Преобразуем строку даты в объект DateTime
        final String dateStr = data['date'] as String;
        final date = DateTime.parse(dateStr);
        
        appointments.add(AppointmentModel.fromMap(doc.id, {
          ...data,
          'date': date,
        }));
      }
      
      return appointments;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении записей пользователя: $e');
      }
      return [];
    }
  }
  
  // Получение предстоящих записей пользователя
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final formattedToday = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('clientId', isEqualTo: userId)
          .where('status', isEqualTo: 'booked')
          // Здесь мы используем "больше или равно" для даты
          .where('date', isGreaterThanOrEqualTo: formattedToday)
          .orderBy('date')
          .orderBy('startTime')
          .get();
      
      final List<AppointmentModel> appointments = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Преобразуем строку даты в объект DateTime
        final String dateStr = data['date'] as String;
        final date = DateTime.parse(dateStr);
        
        appointments.add(AppointmentModel.fromMap(doc.id, {
          ...data,
          'date': date,
        }));
      }
      
      return appointments;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении предстоящих записей: $e');
      }
      return [];
    }
  }
  
  // Получение прошедших записей пользователя
  Future<List<AppointmentModel>> getPastAppointments(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final formattedToday = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Запрос всех записей пользователя
      final QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('clientId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .orderBy('startTime', descending: true)
          .get();
      
      final List<AppointmentModel> appointments = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String dateStr = data['date'] as String;
        final date = DateTime.parse(dateStr);
        final status = data['status'] as String;
        
        // Фильтруем только прошедшие записи или записи со статусом 'completed', 'cancelled', 'no-show'
        final isPastDate = date.isBefore(today);
        final isCompletedStatus = status == 'completed' || status == 'cancelled' || status == 'no-show';
        
        if (isPastDate || isCompletedStatus) {
          appointments.add(AppointmentModel.fromMap(doc.id, {
            ...data,
            'date': date,
          }));
        }
      }
      
      return appointments;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении прошедших записей: $e');
      }
      return [];
    }
  }
  
  // Получение записи по ID
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final String dateStr = data['date'] as String;
        final date = DateTime.parse(dateStr);
        
        return AppointmentModel.fromMap(doc.id, {
          ...data,
          'date': date,
        });
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении записи: $e');
      }
      return null;
    }
  }
  
  // Создание новой записи
  Future<String?> createAppointment({
    required String clientId,
    required String masterId,
    required String serviceId,
    required DateTime date,
    required String startTime,
    required String? notes,
  }) async {
    try {
      // Получаем данные о услуге
      final service = await _servicesService.getServiceById(serviceId);
      if (service == null) {
        throw Exception('Услуга не найдена');
      }
      
      // Получаем данные о мастере
      final master = await _mastersService.getMasterById(masterId);
      if (master == null) {
        throw Exception('Мастер не найден');
      }
      
      // Расчет времени окончания услуги
      final startTimeParts = startTime.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      
      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startHour,
        startMinute,
      );
      
      final endDateTime = startDateTime.add(Duration(minutes: service.duration));
      final endTime = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
      
      // Форматируем дату в формат ГГГГ-ММ-ДД для сохранения в Firestore
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Создаем запись в формате Map для сохранения в Firestore
      final appointmentData = {
        'clientId': clientId,
        'masterId': masterId,
        'masterName': master.displayName,
        'serviceId': serviceId,
        'serviceName': service.name['ru'] ?? '', // Используем русское название по умолчанию
        'date': formattedDate,
        'startTime': startTime,
        'endTime': endTime,
        'price': service.price,
        'status': 'booked',
        'notes': notes,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'reminder15min': false,
        'reminder1hour': false,
        'reminder1day': false,
      };
      
      // Сохраняем в Firestore
      final docRef = await _firestore
          .collection('appointments')
          .add(appointmentData);
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при создании записи: $e');
      }
      return null;
    }
  }
  
  // Отмена записи
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
            'status': 'cancelled',
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при отмене записи: $e');
      }
      return false;
    }
  }
  
  // Проверка возможности отмены записи (за 3 часа до начала)
  Future<bool> canCancelAppointment(String appointmentId) async {
    try {
      final appointment = await getAppointmentById(appointmentId);
      if (appointment == null) {
        return false;
      }
      
      return appointment.canBeCancelled;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при проверке возможности отмены: $e');
      }
      return false;
    }
  }
}