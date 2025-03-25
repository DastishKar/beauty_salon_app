// lib/services/services_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/service_model.dart';
import '../models/category_model.dart';

class ServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Получение всех категорий
  Future<List<CategoryModel>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();
      
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении категорий: $e');
      }
      return [];
    }
  }
  
  // Получение категории по ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();
      
      if (doc.exists) {
        return CategoryModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении категории: $e');
      }
      return null;
    }
  }
  
  // Получение всех услуг
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении услуг: $e');
      }
      return [];
    }
  }
  
  // Получение услуг по категории
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('category', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении услуг по категории: $e');
      }
      return [];
    }
  }
  
  // Получение услуги по ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('services')
          .doc(serviceId)
          .get();
      
      if (doc.exists) {
        return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении услуги: $e');
      }
      return null;
    }
  }
  
  // Поиск услуг по названию
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      // Firebase не поддерживает полнотекстовый поиск напрямую,
      // поэтому получаем все услуги и фильтруем на стороне клиента
      final List<ServiceModel> allServices = await getAllServices();
      
      if (query.isEmpty) {
        return allServices;
      }
      
      final queryLower = query.toLowerCase();
      
      return allServices.where((service) {
        final nameRu = service.name['ru']?.toLowerCase() ?? '';
        final nameKk = service.name['kk']?.toLowerCase() ?? '';
        final nameEn = service.name['en']?.toLowerCase() ?? '';
        
        return nameRu.contains(queryLower) || 
               nameKk.contains(queryLower) || 
               nameEn.contains(queryLower);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при поиске услуг: $e');
      }
      return [];
    }
  }
  
  // Получение популярных услуг
  Future<List<ServiceModel>> getPopularServices({int limit = 5}) async {
    try {
      // Здесь могла бы быть логика получения популярных услуг
      // на основе количества записей или рейтинга
      // Сейчас просто возвращаем первые N активных услуг
      final QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении популярных услуг: $e');
      }
      return [];
    }
  }
}