import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageUploadService {
  // Convert single image to base64
  Future<String> uploadImage(File imageFile, String folderPath) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      if (kDebugMode) {
        print('Error converting image to base64: $e');
      }
      throw Exception('Failed to convert image: $e');
    }
  }
  
  // Convert multiple images to base64
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, String folderPath) async {
    final List<String> base64Strings = [];
    
    for (final file in imageFiles) {
      try {
        final base64String = await uploadImage(file, folderPath);
        base64Strings.add(base64String);
      } catch (e) {
        if (kDebugMode) {
          print('Error converting image to base64: $e');
        }
      }
    }
    
    if (base64Strings.isEmpty && imageFiles.isNotEmpty) {
      throw Exception('Failed to convert any images');
    }
    
    return base64Strings;
  }
}