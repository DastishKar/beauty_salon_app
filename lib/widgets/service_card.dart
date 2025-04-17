// lib/widgets/service_card.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';

import '../models/service_model.dart';
import '../services/language_service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool isSmall;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).languageCode;

    if (isSmall) {
      return _buildSmallCard(context, languageCode);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение услуги
            _buildPhoto(context, size: 120),

            // Информация об услуге
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.getLocalizedName(languageCode),
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${service.price.toString()} ₸',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.duration} мин',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(BuildContext context, {required double size, double iconSize = 30}) {
    Widget photoWidget;
    try {
      if (service.photoBase64 != null && service.photoBase64!.isNotEmpty) {
        photoWidget = AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(
              base64Decode(service.photoBase64!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                if (kDebugMode) {
                  print('Error displaying image in service card: $error');
                }
                return _buildPlaceholder(context, iconSize);
              },
            ),
          ),
        );
      } else {
        photoWidget = AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildPlaceholder(context, iconSize),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in service card photo: $e');
      }
      photoWidget = AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildPlaceholder(context, iconSize),
        ),
      );
    }

    return photoWidget;
  }

  Widget _buildPlaceholder(BuildContext context, double iconSize) {
    return Icon(
      Icons.spa,
      size: iconSize,
      color: Theme.of(context).primaryColor,
    );
  }

  // Компактная версия карточки
  Widget _buildSmallCard(BuildContext context, String languageCode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Миниатюра услуги
              _buildPhoto(context, size: 60, iconSize: 30),
              const SizedBox(width: 12),

              // Информация об услуге
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.getLocalizedName(languageCode),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${service.price.toString()} ₸',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.duration} мин',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}