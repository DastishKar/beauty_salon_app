// lib/widgets/master_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../l10n/app_localizations.dart';
import '../models/master_model.dart';
import '../services/language_service.dart';

class MasterCard extends StatelessWidget {
  final MasterModel master;
  final VoidCallback? onTap;
  final bool isSmall;

  const MasterCard({
    super.key,
    required this.master,
    this.onTap,
    this.isSmall = false,
  });

  Widget _buildPhoto(BuildContext context, {required double size, double iconSize = 50}) {
    Widget photoWidget;
    try {
      if (master.photoBase64 != null && master.photoBase64!.isNotEmpty) {
        photoWidget = Image.memory(
          base64Decode(master.photoBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: iconSize, color: Colors.grey);
          },
        );
      } else {
        photoWidget = Icon(Icons.person, size: iconSize, color: Colors.grey);
      }
    } catch (e) {
      photoWidget = Icon(Icons.person, size: iconSize, color: Colors.grey);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).languageCode;
    AppLocalizations.of(context);

    if (isSmall) {
      return _buildSmallCard(context, languageCode);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPhoto(context, size: 100),
              const SizedBox(height: 12),

              // Имя мастера
              Text(
                master.displayName,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Специализации
              Text(
                master.specializations.join(', '),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Рейтинг
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    master.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${master.reviewsCount})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
              _buildPhoto(context, size: 60, iconSize: 30),
              const SizedBox(width: 12),

              // Информация о мастере
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      master.specializations.join(', '),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          master.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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