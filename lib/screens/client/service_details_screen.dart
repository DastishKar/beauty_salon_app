// lib/screens/client/service_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../l10n/app_localizations.dart';
import '../../models/service_model.dart';
import '../../models/master_model.dart';
import '../../services/language_service.dart';
import '../../services/masters_service.dart';
import '../../widgets/master_card.dart';
import 'master_details_screen.dart';
import 'booking_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;
  final bool isForBooking;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
    this.isForBooking = false,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isLoading = false;
  List<MasterModel> _availableMasters = [];
  final bool _imageHasError = false;

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

    try {
      final mastersService = MastersService();
      final masters = await mastersService.getMastersByService(widget.service.id);

      if (mounted) {
        setState(() {
          _availableMasters = masters;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading masters: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading masters: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Provider.of<LanguageService>(context).languageCode;

    if (kDebugMode) {
      print('Building service details for service: ${widget.service.id}');
      print('photoBase64 available: ${widget.service.photoBase64 != null}');
      if (widget.service.photoBase64 != null) {
        print('photoBase64 length: ${widget.service.photoBase64!.length}');
      }
    }

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
                  // Service image with error handling
                  _buildServiceImage(context),
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

                  // Список карточек мастеров
                  if (_availableMasters.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableMasters.length,
                        itemBuilder: (context, index) {
                          final master = _availableMasters[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: 150,
                              child: MasterCard(
                                master: master,
                                isSmall: true,
                                onTap: () {
                                  // Если мы в режиме бронирования, перейти прямо на экран бронирования с выбранным мастером
                                  if (widget.isForBooking) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BookingScreen(
                                          service: widget.service,
                                          selectedMaster: master,
                                        ),
                                      ),
                                    ).then((result) {
                                      // Если бронирование было успешным, вернемся из всех экранов выбора
                                      if (result == true && mounted) {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst || route.settings.name == '/appointments');
                                      }
                                    });
                                  } else {
                                    // Обычный просмотр деталей мастера
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MasterDetailsScreen(
                                          master: master,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _availableMasters.isEmpty
              ? null
              : () {
                  // Переход на экран бронирования с первым доступным мастером
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        service: widget.service,
                        selectedMaster: _availableMasters.isNotEmpty ? _availableMasters.first : null,
                      ),
                    ),
                  ).then((result) {
                    // Если бронирование было успешным и мы в режиме бронирования,
                    // вернемся обратно на экран записей
                    if (result == true && widget.isForBooking && mounted) {
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst || route.settings.name == '/appointments');
                    }
                  });
                },
          child: Text(localizations.translate('book_service')),
        ),
      ),
    );
  }

  // New method to handle service image display
  Widget _buildServiceImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Builder(
          builder: (context) {
            if (widget.service.photoBase64 == null || widget.service.photoBase64!.isEmpty) {
              return Center(
                child: Icon(
                  Icons.spa,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              );
            }

            try {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(widget.service.photoBase64!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    if (kDebugMode) {
                      print('Error loading service image: $error');
                      print('Stack trace: $stackTrace');
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Could not load image',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } catch (e) {
              if (kDebugMode) {
                print('Error decoding base64 image: $e');
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invalid image format',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}