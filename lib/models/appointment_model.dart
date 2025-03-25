// lib/models/appointment_model.dart

class AppointmentModel {
  final String id;
  final String clientId;
  final String masterId;
  final String masterName;
  final String serviceId;
  final String serviceName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int price;
  final String status; // 'booked', 'completed', 'cancelled', 'no-show'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reminder15min;
  final bool reminder1hour;
  final bool reminder1day;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.masterId,
    required this.masterName,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.reminder15min = false,
    this.reminder1hour = false,
    this.reminder1day = false,
  });

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> data) {
    return AppointmentModel(
      id: id,
      clientId: data['clientId'] ?? '',
      masterId: data['masterId'] ?? '',
      masterName: data['masterName'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      date: data['date'] != null 
          ? DateTime.parse(data['date']) 
          : DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      price: data['price'] ?? 0,
      status: data['status'] ?? 'booked',
      notes: data['notes'],
      createdAt: data['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt']) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt']) 
          : DateTime.now(),
      reminder15min: data['reminder15min'] ?? false,
      reminder1hour: data['reminder1hour'] ?? false,
      reminder1day: data['reminder1day'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'masterId': masterId,
      'masterName': masterName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'reminder15min': reminder15min,
      'reminder1hour': reminder1hour,
      'reminder1day': reminder1day,
    };
  }

  AppointmentModel copyWith({
    String? clientId,
    String? masterId,
    String? masterName,
    String? serviceId,
    String? serviceName,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? price,
    String? status,
    String? notes,
    bool? reminder15min,
    bool? reminder1hour,
    bool? reminder1day,
  }) {
    return AppointmentModel(
      id: id,
      clientId: clientId ?? this.clientId,
      masterId: masterId ?? this.masterId,
      masterName: masterName ?? this.masterName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      reminder15min: reminder15min ?? this.reminder15min,
      reminder1hour: reminder1hour ?? this.reminder1hour,
      reminder1day: reminder1day ?? this.reminder1day,
    );
  }

  // Проверка истекла ли запись
  bool get isExpired {
    final now = DateTime.now();
    final appointmentDate = date.copyWith(
      hour: int.parse(endTime.split(':')[0]),
      minute: int.parse(endTime.split(':')[1]),
    );
    return now.isAfter(appointmentDate);
  }

  // Проверка можно ли отменить запись (за 3 часа до начала)
  bool get canBeCancelled {
    if (status != 'booked') return false;
    
    final now = DateTime.now();
    final appointmentDate = date.copyWith(
      hour: int.parse(startTime.split(':')[0]),
      minute: int.parse(startTime.split(':')[1]),
    );
    final difference = appointmentDate.difference(now).inHours;
    
    return difference >= 3;
  }
}