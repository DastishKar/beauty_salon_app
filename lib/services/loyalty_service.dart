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
        return LoyaltyTransactionModel.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
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

      // Списываем баллы
      final success = await deductPoints(
        userId: userId,
        points: points,
        description: 'Использование акции: $title',
        type: 'redeem',
        referenceId: promotionId,
      );

      if (success) {
        // Создаем запись об использовании акции
        await _firestore.collection('promotion_usages').add({
          'userId': userId,
          'promotionId': promotionId,
          'points': points,
          'date': FieldValue.serverTimestamp(),
        });

        return true;
      }

      return false;
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
}