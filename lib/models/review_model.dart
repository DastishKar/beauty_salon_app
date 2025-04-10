// lib/models/review_model.dart

class ReviewModel {
  final String id;
  final String clientId;
  final String clientName;
  final String? clientPhotoURL;
  final String masterId;
  final String? appointmentId;
  final double rating;
  final String comment;
  final List<String> photoURLs;
  final DateTime createdAt;
  final bool isVerified; // Подтверждено ли, что отзыв от реального клиента

  ReviewModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientPhotoURL,
    required this.masterId,
    this.appointmentId,
    required this.rating,
    required this.comment,
    List<String>? photoURLs,
    required this.createdAt,
    this.isVerified = false,
  }) : photoURLs = photoURLs ?? [];

  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) {
    return ReviewModel(
      id: id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientPhotoURL: data['clientPhotoURL'],
      masterId: data['masterId'] ?? '',
      appointmentId: data['appointmentId'],
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      photoURLs: List<String>.from(data['photoURLs'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
              : (data['createdAt'] is Map && data['createdAt'].containsKey('seconds')
                  ? DateTime.fromMillisecondsSinceEpoch(
                      (data['createdAt']['seconds'] * 1000 +
                              (data['createdAt']['nanoseconds'] ?? 0) / 1000000)
                          .round())
                  : DateTime.now()))
          : DateTime.now(),
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientPhotoURL': clientPhotoURL,
      'masterId': masterId,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'photoURLs': photoURLs,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
    };
  }

  ReviewModel copyWith({
    String? clientName,
    String? clientPhotoURL,
    double? rating,
    String? comment,
    List<String>? photoURLs,
    bool? isVerified,
  }) {
    return ReviewModel(
      id: id,
      clientId: clientId,
      clientName: clientName ?? this.clientName,
      clientPhotoURL: clientPhotoURL ?? this.clientPhotoURL,
      masterId: masterId,
      appointmentId: appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photoURLs: photoURLs ?? List<String>.from(this.photoURLs),
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}