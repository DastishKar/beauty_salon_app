// lib/widgets/promotions_slider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class PromotionsSlider extends StatefulWidget {
  const PromotionsSlider({Key? key}) : super(key: key);

  @override
  _PromotionsSliderState createState() => _PromotionsSliderState();
}

class _PromotionsSliderState extends State<PromotionsSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Заглушка для акций (в будущем будет заменена на данные из Firebase)
  final List<Map<String, dynamic>> _promotions = [
    {
      'title': {
        'ru': 'Скидка 20% на все услуги окрашивания',
        'kk': 'Барлық бояу қызметтеріне 20% жеңілдік',
        'en': '20% off all coloring services',
      },
      'description': {
        'ru': 'Акция действует с 1 по 30 апреля',
        'kk': 'Акция 1-30 сәуір аралығында жарамды',
        'en': 'Promotion valid from April 1 to April 30',
      },
      'color': const Color(0xFFE91E63),
      'icon': Icons.color_lens,
    },
    {
      'title': {
        'ru': 'Приведи друга и получи 1000 бонусных баллов',
        'kk': 'Досыңды әкел және 1000 бонустық ұпай ал',
        'en': 'Refer a friend and get 1000 loyalty points',
      },
      'description': {
        'ru': 'За каждого друга, который впервые посетит наш салон',
        'kk': 'Салонымызға алғаш рет келген әрбір дос үшін',
        'en': 'For each friend who visits our salon for the first time',
      },
      'color': const Color(0xFF4CAF50),
      'icon': Icons.people,
    },
    {
      'title': {
        'ru': 'Комплекс "Маникюр + Педикюр" со скидкой 15%',
        'kk': '15% жеңілдікпен "Маникюр + Педикюр" кешені',
        'en': 'Manicure + Pedicure complex with 15% discount',
      },
      'description': {
        'ru': 'Предложение действует каждый вторник и четверг',
        'kk': 'Ұсыныс әр сейсенбі және бейсенбі күндері жарамды',
        'en': 'Offer valid every Tuesday and Thursday',
      },
      'color': const Color(0xFF9C27B0),
      'icon': Icons.spa,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    // Автоматическое переключение слайдов
    _startAutoSlide();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Автоматическое переключение слайдов
  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % _promotions.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.languageCode;
    
    return Column(
      children: [
        // Слайдер акций
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _promotions.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final promotion = _promotions[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      promotion['color'],
                      promotion['color'].withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Иконка акции
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        promotion['icon'],
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Информация об акции
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promotion['title'][languageCode] ?? 
                            promotion['title']['ru'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promotion['description'][languageCode] ?? 
                            promotion['description']['ru'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Индикаторы слайдера
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promotions.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.5),
              ),
            );
          }),
        ),
      ],
    );
  }
}