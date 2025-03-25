// lib/models/service_model.dart

class ServiceModel {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String category;
  final int duration; // в минутах
  final int price; // в тенге
  final String? photoURL;
  final Map<String, bool> availableMasters;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.duration,
    required this.price,
    this.photoURL,
    required this.availableMasters,
    this.isActive = true,
  });

  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['ru'] ?? '';
  }

  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ?? description['ru'] ?? '';
  }

  factory ServiceModel.fromMap(String id, Map<String, dynamic> data) {
    return ServiceModel(
      id: id,
      name: Map<String, String>.from(data['name'] ?? {}),
      description: Map<String, String>.from(data['description'] ?? {}),
      category: data['category'] ?? '',
      duration: data['duration'] ?? 60,
      price: data['price'] ?? 0,
      photoURL: data['photoURL'],
      availableMasters: Map<String, bool>.from(data['availableMasters'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'duration': duration,
      'price': price,
      'photoURL': photoURL,
      'availableMasters': availableMasters,
      'isActive': isActive,
    };
  }

  ServiceModel copyWith({
    Map<String, String>? name,
    Map<String, String>? description,
    String? category,
    int? duration,
    int? price,
    String? photoURL,
    Map<String, bool>? availableMasters,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? Map<String, String>.from(this.name),
      description: description ?? Map<String, String>.from(this.description),
      category: category ?? this.category,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      photoURL: photoURL ?? this.photoURL,
      availableMasters: availableMasters ?? Map<String, bool>.from(this.availableMasters),
      isActive: isActive ?? this.isActive,
    );
  }
}