// lib/widgets/review_card.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool showMasterInfo;
  final VoidCallback? onDelete;
  
  const ReviewCard({
    super.key,
    required this.review,
    this.showMasterInfo = false,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    // Форматирование даты
    final dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(review.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть с информацией о клиенте и рейтингом
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар клиента с обработкой base64 изображения
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                  child: Builder(
                    builder: (context) {
                      if (review.clientPhotoBase64 == null || review.clientPhotoBase64!.isEmpty) {
                        return const Icon(Icons.person, size: 20, color: Colors.grey);
                      }

                      try {
                        return ClipOval(
                          child: Image.memory(
                            base64Decode(review.clientPhotoBase64!),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              if (kDebugMode) {
                                print('Error loading avatar: $error');
                              }
                              return const Icon(Icons.person, size: 20, color: Colors.grey);
                            },
                          ),
                        );
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error decoding avatar: $e');
                        }
                        return const Icon(Icons.person, size: 20, color: Colors.grey);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Имя клиента и дата
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.clientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (review.isVerified) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: 'Подтвержденный отзыв',
                              child: Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Рейтинг
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                
                // Кнопка удаления (если доступна)
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red,
                    onPressed: onDelete,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            
            // Текст отзыва
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment),
            ],
            
            // Фотографии с обработкой base64 (если есть)
            if (review.photosBase64.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photosBase64.length,
                  itemBuilder: (context, index) {
                    final photoBase64 = review.photosBase64[index];
                    return GestureDetector(
                      onTap: () {
                        // Показ фото на весь экран при нажатии
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(),
                              body: Center(
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  boundaryMargin: const EdgeInsets.all(20),
                                  minScale: 0.5,
                                  maxScale: 4,
                                  child: Builder(
                                    builder: (context) {
                                      try {
                                        return Image.memory(
                                          base64Decode(photoBase64),
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image, size: 50, color: Colors.red);
                                          },
                                        );
                                      } catch (e) {
                                        return const Icon(Icons.error_outline, size: 50, color: Colors.red);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Builder(
                          builder: (context) {
                            try {
                              return Image.memory(
                                base64Decode(photoBase64),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  if (kDebugMode) {
                                    print('Error loading review photo: $error');
                                  }
                                  return const Icon(Icons.broken_image, size: 30, color: Colors.red);
                                },
                              );
                            } catch (e) {
                              if (kDebugMode) {
                                print('Error decoding review photo: $e');
                              }
                              return const Icon(Icons.error_outline, size: 30, color: Colors.red);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}