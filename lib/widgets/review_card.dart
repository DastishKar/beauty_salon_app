// lib/widgets/review_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                // Аватар клиента
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                  backgroundImage: review.clientPhotoURL != null
                      ? NetworkImage(review.clientPhotoURL!)
                      : null,
                  child: review.clientPhotoURL == null
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
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
            
            // Фотографии (если есть)
            if (review.photoURLs.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photoURLs.length,
                  itemBuilder: (context, index) {
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
                                  child: Image.network(
                                    review.photoURLs[index],
                                    fit: BoxFit.contain,
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
                          image: DecorationImage(
                            image: NetworkImage(review.photoURLs[index]),
                            fit: BoxFit.cover,
                          ),
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