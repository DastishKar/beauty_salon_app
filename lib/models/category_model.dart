// lib/models/category_model.dart

class CategoryModel {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String? photoURL;
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.photoURL,
    required this.order,
  });

  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['ru'] ?? '';
  }

  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ?? description['ru'] ?? '';
  }

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: Map<String, String>.from(data['name'] ?? {}),
      description: Map<String, String>.from(data['description'] ?? {}),
      photoURL: data['photoURL'],
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'photoURL': photoURL,
      'order': order,
    };
  }
}