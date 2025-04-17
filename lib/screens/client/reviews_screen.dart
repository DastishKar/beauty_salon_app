// lib/screens/client/reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../l10n/app_localizations.dart';
import '../../models/master_model.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../services/reviews_service.dart';
import '../../widgets/review_card.dart';
import '../../widgets/loading_overlay.dart';
import 'create_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final MasterModel master;
  
  const ReviewsScreen({
    super.key,
    required this.master,
  });
  
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewsService _reviewsService = ReviewsService();
  bool _isLoading = true;
  List<ReviewModel> _reviews = [];
  
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }
  
  Future<void> _loadReviews() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final reviews = await _reviewsService.getMasterReviews(widget.master.id);
      
      if (!mounted) return;
      
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке отзывов: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке отзывов: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  Future<void> _deleteReview(ReviewModel review) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid;
    
    // Проверяем, принадлежит ли отзыв текущему пользователю
    if (currentUserId != null && review.clientId == currentUserId) {
      // Показываем диалог подтверждения
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).translate('delete_review')),
          content: Text(AppLocalizations.of(context).translate('delete_review_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                AppLocalizations.of(context).translate('delete'),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        setState(() {
          _isLoading = true;
        });
        
        try {
          final success = await _reviewsService.deleteReview(review.id, widget.master.id);
          
          if (!mounted) return;
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).translate('review_deleted')),
                backgroundColor: Colors.green,
              ),
            );
            
            // Перезагружаем отзывы
            _loadReviews();
          } else {
            throw Exception('Не удалось удалить отзыв');
          }
        } catch (e) {
          if (!mounted) return;
          
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при удалении отзыва: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.uid;
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('reviews')),
        ),
        body: Column(
          children: [
            // Сводка по отзывам
            _buildReviewsSummary(),
            
            // Список отзывов
            Expanded(
              child: _reviews.isEmpty
                ? Center(
                    child: Text(
                      localizations.translate('no_reviews'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadReviews,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return ReviewCard(
                          review: review,
                          // Показываем кнопку удаления только для отзывов текущего пользователя
                          onDelete: (currentUserId != null && review.clientId == currentUserId)
                              ? () => _deleteReview(review)
                              : null,
                        );
                      },
                    ),
                  ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Переход на экран создания отзыва
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateReviewScreen(master: widget.master),
              ),
            );
            
            // Если отзыв был создан, обновляем список
            if (result == true) {
              _loadReviews();
            }
          },
          child: const Icon(Icons.rate_review),
        ),
      ),
    );
  }
  
  Widget _buildReviewsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          // Фото мастера
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
            backgroundImage: widget.master.photoBase64 != null
                ? MemoryImage(base64Decode(widget.master.photoBase64!))
                : null,
            child: widget.master.photoBase64 == null
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          
          // Информация о мастере и рейтинге
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.master.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Звездочки для рейтинга
                    ...List.generate(5, (index) {
                      return Icon(
                        index < widget.master.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 8),
                    // Числовой рейтинг и количество отзывов
                    Text(
                      '${widget.master.rating.toStringAsFixed(1)} (${widget.master.reviewsCount})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}