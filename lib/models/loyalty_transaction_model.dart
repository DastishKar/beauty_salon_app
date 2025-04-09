// lib/models/loyalty_transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyTransactionModel {
  final String id;
  final String userId;
  final String type; // 'earn', 'redeem', 'bonus'
  final int points;
  final String description;
  final DateTime date;
  final String? referenceId; // ID записи, покупки или акции

  LoyaltyTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.description,
    required this.date,
    this.referenceId,
  });

  factory LoyaltyTransactionModel.fromMap(String id, Map<String, dynamic> data) {
    // Обработка даты из Firestore
    DateTime date = DateTime.now();
    
    if (data['date'] != null) {
      if (data['date'] is Timestamp) {
        // Если это Timestamp из Firestore
        date = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is int) {
        // Если это миллисекунды
        date = DateTime.fromMillisecondsSinceEpoch(data['date']);
      } else if (data['date'] is Map && data['date'].containsKey('seconds')) {
        // Если это Timestamp как Map (содержит seconds и nanoseconds)
        date = DateTime.fromMillisecondsSinceEpoch(
          (data['date']['seconds'] * 1000 + (data['date']['nanoseconds'] ?? 0) / 1000000).round()
        );
      }
    }

    return LoyaltyTransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      points: data['points'] ?? 0,
      description: data['description'] ?? '',
      date: date,
      referenceId: data['referenceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'points': points,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'referenceId': referenceId,
    };
  }
}