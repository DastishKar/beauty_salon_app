// lib/models/review_model.dart

class ReviewModel {
  final String id;
  final String clientId;
  final String clientName;
  final String? clientPhotoBase64; // Changed from clientPhotoURL
  final String masterId;
  final String? appointmentId;
  final double rating;
  final String comment;
  final List<String> photosBase64; // Changed from photoURLs
  final DateTime createdAt;
  final bool isVerified;

  ReviewModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientPhotoBase64,
    required this.masterId,
    this.appointmentId,
    required this.rating,
    required this.comment,
    List<String>? photosBase64,
    required this.createdAt,
    this.isVerified = false,
  }) : photosBase64 = photosBase64 ?? [];

  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) {
    return ReviewModel(
      id: id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientPhotoBase64: data['clientPhotoBase64'],
      masterId: data['masterId'] ?? '',
      appointmentId: data['appointmentId'],
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      photosBase64: List<String>.from(data['photosBase64'] ?? []),
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
      'clientPhotoBase64': clientPhotoBase64,
      'masterId': masterId,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'photosBase64': photosBase64,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
    };
  }

  ReviewModel copyWith({
    String? clientName,
    String? clientPhotoBase64,
    double? rating,
    String? comment,
    List<String>? photosBase64,
    bool? isVerified,
  }) {
    return ReviewModel(
      id: id,
      clientId: clientId,
      clientName: clientName ?? this.clientName,
      clientPhotoBase64: clientPhotoBase64 ?? this.clientPhotoBase64,
      masterId: masterId,
      appointmentId: appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photosBase64: photosBase64 ?? List<String>.from(this.photosBase64),
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}