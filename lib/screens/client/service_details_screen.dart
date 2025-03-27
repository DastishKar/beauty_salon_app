// lib/screens/client/service_details_screen.dart

import 'package:beauty_salon_app/screens/client/master_details_screen.dart';
import 'package:beauty_salon_app/screens/client/booking_screen.dart';
import 'package:beauty_salon_app/services/masters_service.dart';
import 'package:beauty_salon_app/widgets/master_card.dart';
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
      
      // Debug information
      debugPrint('Loading masters for service ID: ${widget.service.id}');
      debugPrint('Service category: ${widget.service.category}');
      debugPrint('Service available masters: ${widget.service.availableMasters}');
      
      final masters = await mastersService.getMastersByService(widget.service.id);
      
      // Debug the results
      debugPrint('Found ${masters.length} masters for this service');
      if (masters.isNotEmpty) {
        debugPrint('First master name: ${masters.first.displayName}');
      }
      
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
                            onError: (exception, stackTrace) {
                              // Просто обрабатываем ошибку - не возвращаем виджет!
                              debugPrint('Error loading image: $exception');
                            },
                          )
                        : null,
                    ),
                    alignment: Alignment.center,
                    child: (widget.service.photoURL == null) || _imageHasError
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
                      child: Column(
                        children: [
                          Text(
                            localizations.translate('no_available_masters'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          // Show debug info for no masters only in debug mode
                          if (Theme.of(context).platform == TargetPlatform.android) 
                          Text(
                            'Service ID: ${widget.service.id}, Category: ${widget.service.category}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                   //Список карточек мастеров будет здесь
                  if (_availableMasters.isNotEmpty)
                   SizedBox(
                     height: 200, // Increased height for better visibility
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableMasters.length,
                        itemBuilder: (context, index) {
                          final master = _availableMasters[index];
                           return Padding(
                             padding: const EdgeInsets.only(right: 12.0),
                             child: SizedBox(
                               width: 150, // Set fixed width for better layout
                               child: MasterCard(
                                 master: master,
                                 isSmall: true,
                                 onTap: () {
                                   Navigator.of(context).push(
                                     MaterialPageRoute(
                                       builder: (context) => MasterDetailsScreen(
                                         master: master,
                                        ),
                                      ),
                                    );
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
              ? null  // Disable button if no masters available
              : () {
                  // Navigate to booking screen with first available master
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        service: widget.service,
                        selectedMaster: _availableMasters.isNotEmpty ? _availableMasters.first : null,
                      ),
                    ),
                  );
                },
          child: Text(localizations.translate('book_service')),
        ),
      ),
    );
  }
}