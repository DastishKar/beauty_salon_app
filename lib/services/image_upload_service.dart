import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Загрузка одного изображения
  Future<String> uploadImage(File imageFile, String folderPath) async {
    try {
      // Создаем уникальное имя файла с расширением
      final String fileExtension = path.extension(imageFile.path);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // Проверяем, что путь корректный
      if (folderPath.startsWith('/')) {
        folderPath = folderPath.substring(1);
      }
      
      if (kDebugMode) {
        print('Загрузка файла: $fileName в путь: $folderPath');
      }
      
      // Получаем ссылку на место в хранилище
      final Reference ref = _storage.ref().child('$folderPath/$fileName');
      
      // Проверяем права доступа (логирование)
      try {
        await ref.getMetadata().catchError((e) {
          if (kDebugMode) {
            print('Метаданные не найдены, это ожидаемо для новой загрузки: $e');
          }
        });
      } catch (e) {
        // Игнорируем ошибку, так как мы создаем новый файл
        if (kDebugMode) {
          print('Проверка метаданных: $e');
        }
      }
      
      // Создаем метаданные для изображения
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'created': DateTime.now().toString()}
      );
      
      // Запускаем загрузку с метаданными
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      
      // Обрабатываем ошибки загрузки
      uploadTask.catchError((e) {
        if (kDebugMode) {
          print('Ошибка во время загрузки: $e');
        }
        throw Exception('Ошибка загрузки: $e');
      });
      
      // Слушаем состояние загрузки для отладки
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (kDebugMode) {
          print('Прогресс загрузки: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        }
      }, onError: (e) {
        if (kDebugMode) {
          print('Ошибка в прослушивателе загрузки: $e');
        }
      });
      
      // Ожидаем завершения загрузки
      final TaskSnapshot snapshot = await uploadTask;
      
      // Получаем URL загруженного файла
      final String downloadURL = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Файл успешно загружен, URL: $downloadURL');
      }
      
      return downloadURL;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('FirebaseException при загрузке изображения: ${e.code}, ${e.message}');
      }
      
      throw Exception('Не удалось загрузить изображение: [${e.code}] ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Общая ошибка при загрузке изображения: $e');
      }
      
      throw Exception('Не удалось загрузить изображение: $e');
    }
  }
  
  // Загрузка нескольких изображений
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, String folderPath) async {
    final List<String> downloadURLs = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        // Загружаем каждый файл отдельно
        final String url = await uploadImage(imageFiles[i], '$folderPath/multiple');
        downloadURLs.add(url);
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка при загрузке файла $i: $e');
        }
        // Продолжаем с оставшимися файлами
      }
    }
    
    // Если не удалось загрузить ни одного файла, выбрасываем исключение
    if (downloadURLs.isEmpty && imageFiles.isNotEmpty) {
      throw Exception('Не удалось загрузить ни одно изображение');
    }
    
    return downloadURLs;
  }
  
  // Удаление изображения
  Future<void> deleteImage(String imageURL) async {
    try {
      if (imageURL.isEmpty) {
        if (kDebugMode) {
          print('Пустой URL изображения, ничего не удаляем');
        }
        return;
      }
      
      final Reference ref = _storage.refFromURL(imageURL);
      await ref.delete();
      
      if (kDebugMode) {
        print('Изображение успешно удалено: $imageURL');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('FirebaseException при удалении изображения: ${e.code}, ${e.message}');
      }
      
      // Не выбрасываем исключение, если файл не найден (он может быть уже удален)
      if (e.code != 'object-not-found') {
        throw Exception('Ошибка при удалении: [${e.code}] ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении изображения: $e');
      }
      // Не выбрасываем исключение при удалении, чтобы не блокировать обновление профиля
    }
  }
}