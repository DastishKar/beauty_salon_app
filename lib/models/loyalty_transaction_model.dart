// lib/models/loyalty_transaction_model.dart

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
    return LoyaltyTransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      points: data['points'] ?? 0,
      description: data['description'] ?? '',
      date: data['date'] != null
          ? (data['date'] is DateTime
              ? data['date']
              : DateTime.fromMillisecondsSinceEpoch(data['date']))
          : DateTime.now(),
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