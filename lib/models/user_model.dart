// lib/models/user_model.dart

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? photoBase64; // Changed from photoURL
  final String role; // 'client', 'admin', 'master'
  final String language; // 'ru', 'kk', 'en'
  final DateTime createdAt;
  final int loyaltyPoints;
  final Map<String, bool> favorites;
  final Map<String, bool> notifications;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.photoBase64, // Changed from photoURL
    required this.role,
    required this.language,
    required this.createdAt,
    this.loyaltyPoints = 0,
    Map<String, bool>? favorites,
    Map<String, bool>? notifications,
  }) : 
    favorites = favorites ?? {},
    notifications = notifications ?? {'push': true, 'email': true, 'sms': false};

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoBase64: data['photoBase64'] as String?, // Changed from photoURL
      role: data['role'] ?? 'client',
      language: data['language'] ?? 'ru',
      createdAt: data['createdAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(data['createdAt']) 
        : DateTime.now(),
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      favorites: Map<String, bool>.from(data['favorites'] ?? {}),
      notifications: Map<String, bool>.from(data['notifications'] ?? {'push': true, 'email': true, 'sms': false}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoBase64': photoBase64, // Changed from photoURL
      'role': role,
      'language': language,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'loyaltyPoints': loyaltyPoints,
      'favorites': favorites,
      'notifications': notifications,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoBase64, // Changed from photoURL
    String? role,
    String? language,
    int? loyaltyPoints,
    Map<String, bool>? favorites,
    Map<String, bool>? notifications,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoBase64: photoBase64 ?? this.photoBase64, // Changed from photoURL
      role: role ?? this.role,
      language: language ?? this.language,
      createdAt: createdAt,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      favorites: favorites ?? Map<String, bool>.from(this.favorites),
      notifications: notifications ?? Map<String, bool>.from(this.notifications),
    );
  }
}