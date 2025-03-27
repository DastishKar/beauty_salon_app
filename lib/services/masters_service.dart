// lib/services/masters_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/master_model.dart';

class MastersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Получение всех мастеров
  Future<List<MasterModel>> getAllMasters() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('masters')
          .get();
      
      return snapshot.docs.map((doc) {
        return MasterModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении мастеров: $e');
      }
      return [];
    }
  }
  
  // Получение мастера по ID
  Future<MasterModel?> getMasterById(String masterId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('masters')
          .doc(masterId)
          .get();
      
      if (doc.exists) {
        return MasterModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении мастера: $e');
      }
      return null;
    }
  }
  
  // Получение мастеров по услуге
  Future<List<MasterModel>> getMastersByService(String serviceId) async {
    try {
      // Получаем информацию об услуге для проверки доступных мастеров
      final serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      
      if (!serviceDoc.exists) {
        return [];
      }
      
      final serviceData = serviceDoc.data() as Map<String, dynamic>;
      final availableMasters = Map<String, bool>.from(serviceData['availableMasters'] ?? {});
      
      if (availableMasters.isEmpty) {
        return [];
      }
      
      // Получаем только тех мастеров, которые могут выполнять данную услугу
      final List<MasterModel> masters = [];
      
      // Используем батч-запросы для эффективного получения мастеров
      final batch = <Future<DocumentSnapshot>>[];
      
      availableMasters.forEach((masterId, isAvailable) {
        if (isAvailable) {
          batch.add(_firestore.collection('masters').doc(masterId).get());
        }
      });
      
      final results = await Future.wait(batch);
      
      for (var doc in results) {
        if (doc.exists) {
          masters.add(MasterModel.fromMap(doc.id, doc.data() as Map<String, dynamic>));
        }
      }
      
      return masters;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении мастеров по услуге: $e');
      }
      return [];
    }
  }
  
  // Получение мастеров по специализации
  Future<List<MasterModel>> getMastersBySpecialization(String specialization) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('masters')
          .get();
      
      final List<MasterModel> masters = snapshot.docs.map((doc) {
        return MasterModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      return masters.where((master) => 
        master.specializations.contains(specialization)
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении мастеров по специализации: $e');
      }
      return [];
    }
  }
  
  // Получение доступных временных слотов мастера на определенную дату
  Future<List<String>> getAvailableTimeSlots(String masterId, DateTime date) async {
    try {
      // Получаем мастера для доступа к его расписанию
      final master = await getMasterById(masterId);
      if (master == null) {
        return [];
      }
      
      // Получаем день недели (понедельник, вторник и т.д.)
      final weekday = _getWeekdayName(date.weekday);
      
      // Получаем рабочее расписание мастера на этот день
      final daySchedule = master.schedule[weekday];
      if (daySchedule == null) {
        // Мастер не работает в этот день
        return [];
      }
      
      // Получаем уже существующие записи к мастеру на эту дату
      final existingAppointments = await _getExistingAppointments(masterId, date);
      
      // Генерируем свободные временные слоты с учетом существующих записей
      return _generateAvailableTimeSlots(daySchedule, existingAppointments);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении доступных временных слотов: $e');
      }
      return [];
    }
  }
  
  // Вспомогательный метод для получения названия дня недели
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }
  
  // Получение существующих записей к мастеру на определенную дату
  Future<List<Map<String, String>>> _getExistingAppointments(String masterId, DateTime date) async {
    try {
      // Форматируем дату в формат ГГГГ-ММ-ДД для сравнения с базой данных
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('masterId', isEqualTo: masterId)
          .where('date', isEqualTo: formattedDate)
          .where('status', isEqualTo: 'booked')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'startTime': data['startTime'] as String,
          'endTime': data['endTime'] as String,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении существующих записей: $e');
      }
      return [];
    }
  }
  
  // Генерация свободных временных слотов
  List<String> _generateAvailableTimeSlots(
    DaySchedule daySchedule,
    List<Map<String, String>> existingAppointments
  ) {
    // Определяем начальное и конечное время работы
    final startTimeParts = daySchedule.start.split(':');
    final endTimeParts = daySchedule.end.split(':');
    
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1]);
    
    // Создаем временные слоты с шагом 30 минут
    final List<String> allSlots = [];
    var currentHour = startHour;
    var currentMinute = startMinute;
    
    while (currentHour < endHour || (currentHour == endHour && currentMinute < endMinute)) {
      final timeSlot = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
      allSlots.add(timeSlot);
      
      // Переходим к следующему временному слоту
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentHour += 1;
        currentMinute = 0;
      }
    }
    
    // Исключаем временные слоты, которые уже заняты
    final List<String> availableSlots = [];
    
    for (var slot in allSlots) {
      bool isAvailable = true;
      
      // Проверяем, не пересекается ли слот с существующими записями
      for (var appointment in existingAppointments) {
        final appointmentStart = appointment['startTime']!;
        final appointmentEnd = appointment['endTime']!;
        
        // Сравниваем временные строки корректно
        // Слот недоступен, если он начинается после начала записи, но до её окончания
        // или если запись начинается во время этого слота
        if ((slot.compareTo(appointmentStart) >= 0 && slot.compareTo(appointmentEnd) < 0) ||
            (appointmentStart.compareTo(slot) >= 0 && appointmentStart.compareTo(_getNextTimeSlot(slot)) < 0)) {
          isAvailable = false;
          break;
        }
      }
      
      // Проверяем, не попадает ли слот в перерыв
      for (var breakTime in daySchedule.breaks) {
        if (slot.compareTo(breakTime.start) >= 0 && slot.compareTo(breakTime.end) < 0) {
          isAvailable = false;
          break;
        }
      }
      
      if (isAvailable) {
        availableSlots.add(slot);
      }
    }
    
    return availableSlots;
  }
  
  // Вспомогательный метод для получения следующего временного слота
  String _getNextTimeSlot(String timeSlot) {
    final parts = timeSlot.split(':');
    var hour = int.parse(parts[0]);
    var minute = int.parse(parts[1]) + 30;
    
    if (minute >= 60) {
      hour += 1;
      minute = 0;
    }
    
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}