// lib/services/services_service.dart

import 'dart:io';

import 'package:beauty_salon_app/models/appointment_model.dart';
import 'package:beauty_salon_app/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/service_model.dart';
import '../models/category_model.dart';

class ServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();
  
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
  
  // Получение услуг, выполняемых мастером
  Future<List<ServiceModel>> getServicesByMaster(String masterId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();
      
      final List<ServiceModel> services = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final availableMasters = Map<String, bool>.from(data['availableMasters'] ?? {});
        
        // Проверяем, может ли этот мастер выполнять услугу
        if (availableMasters.containsKey(masterId) && availableMasters[masterId] == true) {
          services.add(ServiceModel.fromMap(doc.id, data));
        }
      }
      
      return services;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении услуг мастера: $e');
      }
      return [];
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
  // Обновление данных услуги
  Future<bool> updateService({
    required String serviceId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String category,
    required int price,
    required int duration,
    required bool isActive,
    File? photoFile,
    String? currentPhotoBase64,
  }) async {
    try {
      // Загружаем новое фото, если оно выбрано
      String? photoBase64 = currentPhotoBase64;
      if (photoFile != null) {
        photoBase64 = await _imageUploadService.uploadImage(photoFile, 'services');
      }
    
      // Обновляем данные услуги
      final Map<String, dynamic> updateData = {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'duration': duration,
        'isActive': isActive,
      };
    
      // Добавляем photoBase64 только если он не null
      if (photoBase64 != null) {
        updateData['photoBase64'] = photoBase64;
      }
    
      // Обновляем документ в Firestore
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update(updateData);
    
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении услуги: $e');
      }
      return false;
    }
  }

  // Удаление услуги
  Future<bool> deleteService(String serviceId) async {
    try {
      // Удаляем документ из Firestore
      await _firestore
          .collection('services')
          .doc(serviceId)
          .delete();
    
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении услуги: $e');
      }
      return false;
    }
  }
  

  // Method to create a new service
  Future<String?> createService({
    required Map<String, String> name,
    required Map<String, String> description,
    required String category,
    required int price,
    required int duration,
    required bool isActive,
    File? photoFile,
  }) async {
    try {
      // Upload photo if provided
      String? photoBase64;
      if (photoFile != null) {
        photoBase64 = await _imageUploadService.uploadImage(photoFile, 'services');
      }
      
      // Create service data
      final serviceData = {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'duration': duration,
        'photoBase64': photoBase64,
        'availableMasters': {},
        'isActive': isActive,
      };
      
      // Save to Firestore
      final DocumentReference docRef = await _firestore
          .collection('services')
          .add(serviceData);
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating service: $e');
      }
      return null;
    }
  }
  
  
  // Method to update service photo
  Future<bool> updateServicePhoto(String serviceId, File photoFile) async {
    try {
      final imageUploadService = ImageUploadService();
      final base64String = await imageUploadService.uploadImage(photoFile, 'services');
      
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update({
            'photoBase64': base64String,
          });
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating service photo: $e');
      }
      return false;
    }
  }
}