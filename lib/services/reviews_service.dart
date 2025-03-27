// lib/services/reviews_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/review_model.dart';

class ReviewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Получение отзывов для мастера
  Future<List<ReviewModel>> getMasterReviews(String masterId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('masterId', isEqualTo: masterId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении отзывов мастера: $e');
      }
      return [];
    }
  }

  // Получение отзывов пользователя
  Future<List<ReviewModel>> getClientReviews(String clientId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении отзывов клиента: $e');
      }
      return [];
    }
  }

  // Создание нового отзыва
  Future<String?> createReview({
    required String clientId,
    required String clientName,
    String? clientPhotoURL,
    required String masterId,
    String? appointmentId,
    required double rating,
    required String comment,
    List<File>? photoFiles,
  }) async {
    try {
      // Загружаем фотографии, если они есть
      List<String> photoURLs = [];
      if (photoFiles != null && photoFiles.isNotEmpty) {
        photoURLs = await _uploadPhotos(clientId, masterId, photoFiles);
      }

      // Определяем, является ли отзыв подтвержденным (если есть ID записи)
      final bool isVerified = appointmentId != null;

      // Создаем отзыв в Firestore
      final reviewData = {
        'clientId': clientId,
        'clientName': clientName,
        'clientPhotoURL': clientPhotoURL,
        'masterId': masterId,
        'appointmentId': appointmentId,
        'rating': rating,
        'comment': comment,
        'photoURLs': photoURLs,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': isVerified,
      };

      final docRef = await _firestore.collection('reviews').add(reviewData);

      // Обновляем средний рейтинг мастера
      await _updateMasterRating(masterId);

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при создании отзыва: $e');
      }
      return null;
    }
  }

  // Загрузка фотографий в Storage
  Future<List<String>> _uploadPhotos(
      String clientId, String masterId, List<File> photoFiles) async {
    try {
      final List<String> photoURLs = [];

      for (var i = 0; i < photoFiles.length; i++) {
        final file = photoFiles[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final path = 'reviews/$masterId/${clientId}_$fileName';

        final uploadTask = _storage.ref().child(path).putFile(file);
        final snapshot = await uploadTask;
        final downloadURL = await snapshot.ref.getDownloadURL();

        photoURLs.add(downloadURL);
      }

      return photoURLs;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке фотографий: $e');
      }
      return [];
    }
  }

  // Обновление среднего рейтинга мастера
  Future<void> _updateMasterRating(String masterId) async {
    try {
      final QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('masterId', isEqualTo: masterId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        return;
      }

      // Рассчитываем средний рейтинг
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] is int)
            ? (data['rating'] as int).toDouble()
            : (data['rating'] ?? 0.0).toDouble();
      }

      final averageRating = totalRating / reviewsSnapshot.docs.length;
      final reviewsCount = reviewsSnapshot.docs.length;

      // Обновляем данные мастера
      await _firestore.collection('masters').doc(masterId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'reviewsCount': reviewsCount,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении рейтинга мастера: $e');
      }
    }
  }

  // Удаление отзыва
  Future<bool> deleteReview(String reviewId, String masterId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      
      // Обновляем средний рейтинг мастера после удаления отзыва
      await _updateMasterRating(masterId);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении отзыва: $e');
      }
      return false;
    }
  }
  
  // Проверка, оставил ли клиент отзыв о записи
  Future<bool> hasClientReviewedAppointment(String clientId, String appointmentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('clientId', isEqualTo: clientId)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при проверке отзыва: $e');
      }
      return false;
    }
  }
}