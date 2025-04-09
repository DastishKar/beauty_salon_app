// lib/services/loyalty_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/loyalty_transaction_model.dart';

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение баллов лояльности пользователя
  Future<int> getUserPoints(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['loyaltyPoints'] ?? 0;
      }

      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении баллов лояльности: $e');
      }
      return 0;
    }
  }

  // Получение истории транзакций пользователя
  Future<List<LoyaltyTransactionModel>> getUserTransactions(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('loyalty_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Исправляем обработку даты (timestamp)
        if (data['date'] != null) {
          if (data['date'] is Timestamp) {
            // Преобразуем Timestamp в DateTime для модели
            // Но оставляем его как есть, так как модель умеет обрабатывать Timestamp
          }
        }
        
        return LoyaltyTransactionModel.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении истории транзакций: $e');
      }
      return [];
    }
  }

  // Начисление баллов лояльности
  Future<bool> addPoints({
    required String userId,
    required int points,
    required String description,
    String type = 'earn',
    String? referenceId,
  }) async {
    try {
      // Начало транзакции
      return await _firestore.runTransaction<bool>((transaction) async {
        // Получаем текущий документ пользователя
        final DocumentSnapshot userDoc = await transaction.get(
            _firestore.collection('users').doc(userId));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final currentPoints = userData['loyaltyPoints'] ?? 0;
        final newPoints = currentPoints + points;

        // Обновляем баллы пользователя
        transaction.update(_firestore.collection('users').doc(userId), {
          'loyaltyPoints': newPoints,
        });

        // Создаем запись о транзакции
        final transactionRef = _firestore.collection('loyalty_transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': type,
          'points': points,
          'description': description,
          'date': FieldValue.serverTimestamp(),
          'referenceId': referenceId,
        });

        return true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при начислении баллов: $e');
      }
      return false;
    }
  }

  // Списание баллов лояльности
  Future<bool> deductPoints({
    required String userId,
    required int points,
    required String description,
    String type = 'redeem',
    String? referenceId,
  }) async {
    try {
      // Начало транзакции
      return await _firestore.runTransaction<bool>((transaction) async {
        // Получаем текущий документ пользователя
        final DocumentSnapshot userDoc = await transaction.get(
            _firestore.collection('users').doc(userId));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final currentPoints = userData['loyaltyPoints'] ?? 0;

        // Проверяем, достаточно ли баллов
        if (currentPoints < points) {
          throw Exception('Not enough points');
        }

        final newPoints = currentPoints - points;

        // Обновляем баллы пользователя
        transaction.update(_firestore.collection('users').doc(userId), {
          'loyaltyPoints': newPoints,
        });

        // Создаем запись о транзакции (отрицательные баллы)
        final transactionRef = _firestore.collection('loyalty_transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': type,
          'points': -points, // Отрицательное значение для списания
          'description': description,
          'date': FieldValue.serverTimestamp(),
          'referenceId': referenceId,
        });

        return true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при списании баллов: $e');
      }
      return false;
    }
  }

  // Получение доступных акций
  Future<List<Map<String, dynamic>>> getAvailablePromotions() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      final QuerySnapshot snapshot = await _firestore
          .collection('promotions')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: now)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении доступных акций: $e');
      }
      return [];
    }
  }

  // Получение использованных акций пользователя
  Future<List<Map<String, dynamic>>> getUserRedeemedPromotions(String userId) async {
    try {
      // Получаем использования акций пользователем
      final QuerySnapshot usageSnapshot = await _firestore
          .collection('promotion_usages')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      // Извлекаем ID акций
      final List<String> promotionIds = usageSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['promotionId'] as String)
          .toList();
      
      if (promotionIds.isEmpty) {
        return [];
      }
      
      // Ограничение для запросов Firestore
      const int batchSize = 10;
      final List<Map<String, dynamic>> results = [];
      
      // Обрабатываем акции партиями
      for (int i = 0; i < promotionIds.length; i += batchSize) {
        final end = (i + batchSize < promotionIds.length) ? i + batchSize : promotionIds.length;
        final batch = promotionIds.sublist(i, end);
        
        final QuerySnapshot promoSnapshot = await _firestore
            .collection('promotions')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        for (final promoDoc in promoSnapshot.docs) {
          final promoData = promoDoc.data() as Map<String, dynamic>;
          
          // Находим соответствующую запись использования для получения даты
          // Исправленная версия без orElse
          QueryDocumentSnapshot? usageDoc;
          try {
            usageDoc = usageSnapshot.docs.firstWhere(
              (doc) => (doc.data() as Map<String, dynamic>)['promotionId'] == promoDoc.id,
            );
          } catch (e) {
            // Если не найдено, используем первый документ
            usageDoc = usageSnapshot.docs.isNotEmpty ? usageSnapshot.docs.first : null;
          }
          
          if (usageDoc == null) continue; // Пропускаем если нет связанного документа
          
          final usageData = usageDoc.data() as Map<String, dynamic>;
          
          // Обработка даты (timestamp)
          dynamic redeemedAt = usageData['date'];
          if (redeemedAt is Timestamp) {
            redeemedAt = redeemedAt.toDate().millisecondsSinceEpoch;
          }
          
          // Добавляем данные акции с дополнительной информацией об использовании
          final combinedData = {
            ...promoData,
            'id': promoDoc.id,
            'redeemedAt': redeemedAt,
            'usageId': usageDoc.id,
            'promoCode': usageData['promoCode'] ?? _generatePromoCode(promoDoc.id),
          };
          
          results.add(combinedData);
        }
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении использованных акций: $e');
      }
      return [];
    }
  }

  // Генерация промокода из строки
  String _generatePromoCode(String input) {
    // Используем первые 8 символов ID и делаем их заглавными
    final code = input.substring(0, input.length > 8 ? 8 : input.length).toUpperCase();
    return code;
  }

  // Использование акции
  Future<bool> redeemPromotion({
    required String userId,
    required String promotionId,
    required int points,
  }) async {
    try {
      // Получаем акцию
      final DocumentSnapshot promotionDoc = await _firestore
          .collection('promotions')
          .doc(promotionId)
          .get();

      if (!promotionDoc.exists) {
        throw Exception('Promotion not found');
      }

      final promotionData = promotionDoc.data() as Map<String, dynamic>;
      final isActive = promotionData['isActive'] ?? false;
      final endDate = promotionData['endDate'] ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Проверяем, активна ли акция и не истек ли срок
      if (!isActive || endDate < now) {
        throw Exception('Promotion is not active or expired');
      }

      // Получаем локализованное название акции для описания транзакции
      final title = (promotionData['title'] as Map?)!.containsKey('ru')
          ? promotionData['title']['ru']
          : 'Акция';
          
      // Начинаем транзакцию для атомарности
      return await _firestore.runTransaction<bool>((transaction) async {
        // Получаем текущий документ пользователя
        final DocumentSnapshot userDoc = await transaction.get(
            _firestore.collection('users').doc(userId));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final currentPoints = userData['loyaltyPoints'] ?? 0;

        // Проверяем, достаточно ли баллов
        if (currentPoints < points) {
          throw Exception('Not enough points');
        }

        final newPoints = currentPoints - points;

        // Обновляем баллы пользователя
        transaction.update(_firestore.collection('users').doc(userId), {
          'loyaltyPoints': newPoints,
        });

        // Создаем запись о транзакции
        final transactionRef = _firestore.collection('loyalty_transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': 'redeem',
          'points': -points,
          'description': 'Использование акции: $title',
          'date': FieldValue.serverTimestamp(),
          'referenceId': promotionId,
        });

        // Генерируем уникальный промокод
        final promoCode = _generatePromoCode(promotionId + now.toString());

        // Создаем запись об использовании акции
        final usageRef = _firestore.collection('promotion_usages').doc();
        transaction.set(usageRef, {
          'userId': userId,
          'promotionId': promotionId,
          'points': points,
          'date': FieldValue.serverTimestamp(),
          'promoCode': promoCode,
          'isUsed': false,
        });

        return true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при использовании акции: $e');
      }
      return false;
    }
  }

  // Рассчитать баллы за запись
  int calculatePointsForAppointment(int price) {
    // Например, 1 балл за каждые 100 единиц цены
    return (price / 100).floor();
  }

  // Начислить баллы за запись
  Future<bool> addPointsForAppointment({
    required String userId,
    required String appointmentId,
    required String serviceName,
    required int price,
  }) async {
    final points = calculatePointsForAppointment(price);
    return addPoints(
      userId: userId,
      points: points,
      description: 'Запись на услугу: $serviceName',
      type: 'earn',
      referenceId: appointmentId,
    );
  }

  // Начислить бонусные баллы (например, за приглашение друга)
  Future<bool> addBonusPoints({
    required String userId,
    required int points,
    required String reason,
  }) async {
    return addPoints(
      userId: userId,
      points: points,
      description: reason,
      type: 'bonus',
    );
  }
  
  // Отметить акцию как использованную в салоне
  Future<bool> markPromotionAsUsed(String usageId) async {
    try {
      await _firestore
          .collection('promotion_usages')
          .doc(usageId)
          .update({
            'isUsed': true,
            'usedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при отметке акции как использованной: $e');
      }
      return false;
    }
  }
  
  // Проверить, была ли использована акция
  Future<bool> isPromotionUsed(String usageId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('promotion_usages')
          .doc(usageId)
          .get();
          
      if (!doc.exists) {
        return false;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return data['isUsed'] ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при проверке использования акции: $e');
      }
      return false;
    }
  }
}