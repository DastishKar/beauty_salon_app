// lib/screens/client/service_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/service_model.dart';
import '../../models/master_model.dart';
import '../../services/language_service.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isLoading = false;
  final List<MasterModel> _availableMasters = [];
  
  @override
  void initState() {
    super.initState();
    _loadMasters();
  }
  
  // Загрузка мастеров, которые выполняют данную услугу
  Future<void> _loadMasters() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Реализовать загрузку мастеров из Firestore
    // Пока используем заглушку
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Provider.of<LanguageService>(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.getLocalizedName(languageCode)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение услуги
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                      borderRadius: BorderRadius.circular(16),
                      image: widget.service.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(widget.service.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: widget.service.photoURL == null
                        ? Icon(
                            Icons.spa,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Название и информация
                  Text(
                    widget.service.getLocalizedName(languageCode),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  
                  // Цена и продолжительность
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.service.price} ₸',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.service.duration} ${localizations.translate('minutes')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Описание
                  Text(
                    localizations.translate('description'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.service.getLocalizedDescription(languageCode),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Доступные мастера
                  Text(
                    localizations.translate('available_masters'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_availableMasters.isEmpty)
                    Center(
                      child: Text(
                        localizations.translate('no_available_masters'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  
                  // Список карточек мастеров будет здесь
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Переход на экран бронирования
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => BookingScreen(service: widget.service),
            //   ),
            // );
          },
          child: Text(localizations.translate('book_service')),
        ),
      ),
    );
  }
}