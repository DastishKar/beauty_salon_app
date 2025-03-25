// lib/widgets/service_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_model.dart';
import '../services/language_service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool isSmall;
  
  const ServiceCard({
    Key? key,
    required this.service,
    this.onTap,
    this.isSmall = false,
  }) : super(key: key);
  
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
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                image: service.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(service.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: service.photoURL == null
                  ? Icon(
                      Icons.spa,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            ),
            
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: service.photoURL != null
                      ? DecorationImage(
                          image: NetworkImage(service.photoURL!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: service.photoURL == null
                    ? Icon(
                        Icons.spa,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
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