// lib/screens/client/master_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/master_model.dart';
import '../../models/service_model.dart';
import '../../services/language_service.dart';
import '../../services/services_service.dart';
import '../../widgets/service_card.dart';
import 'booking_screen.dart';
import 'reviews_screen.dart';
import 'create_review_screen.dart';

class MasterDetailsScreen extends StatefulWidget {
  final MasterModel master;

  const MasterDetailsScreen({
    super.key,
    required this.master,
  });

  @override
  State<MasterDetailsScreen> createState() => _MasterDetailsScreenState();
}

class _MasterDetailsScreenState extends State<MasterDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<ServiceModel> _services = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadServices();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Загрузка услуг, которые выполняет мастер
  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });
  
    try {
      final servicesService = ServicesService();
      final services = await servicesService.getServicesByMaster(widget.master.id);
      
      if (!mounted) return;
      
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      debugPrint('Error loading services: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading services: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Provider.of<LanguageService>(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.master.displayName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Верхняя часть с фото и именем мастера
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(widget.master.displayName),
                    background: widget.master.photoURL != null
                        ? Image.network(
                            widget.master.photoURL!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                
                // Табы для навигации по секциям информации
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: localizations.translate('about')),
                        Tab(text: localizations.translate('portfolio')),
                        Tab(text: localizations.translate('schedule')),
                        Tab(text: localizations.translate('reviews')),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
                
                // Контент табов
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Вкладка О мастере
                      _buildAboutTab(context, localizations, languageCode),
                      
                      // Вкладка Портфолио
                      _buildPortfolioTab(context),
                      
                      // Вкладка Расписание
                      _buildScheduleTab(context, localizations),
                      
                      // Вкладка Отзывы
                      _buildReviewsTab(context, localizations),
                    ],
                  ),
                ),
              ],
            ),
      
      // Кнопка для записи к мастеру
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            if (_services.isNotEmpty) {
              Navigator.of(context).push(
               MaterialPageRoute(
                 builder: (context) => BookingScreen(
                   service: _services[0], // Передаем первую услугу из списка
                   selectedMaster: widget.master,
                  ),
                ),
              );
            } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(localizations.translate('no_services_available')),
               ),
             );
            }
          },
          child: Text(localizations.translate('book_with_master')),
        ),
      ),
    );
  }

  // Содержимое вкладки О мастере
  Widget _buildAboutTab(BuildContext context, AppLocalizations localizations, String languageCode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о мастере
          Text(
            localizations.translate('about_master'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            widget.master.getLocalizedDescription(languageCode),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Специализации
          Text(
            localizations.translate('specializations'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.master.specializations.map((specialization) {
              return Chip(
                label: Text(specialization),
                backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Опыт работы
          Row(
            children: [
              Icon(
                Icons.work,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${localizations.translate('experience')}: ${widget.master.experience}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Рейтинг
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.master.rating.toStringAsFixed(1)} (${widget.master.reviewsCount} ${localizations.translate('reviews')})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Услуги мастера
          Text(
            localizations.translate('services'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          _services.isEmpty
              ? Center(
                  child: Text(
                    localizations.translate('no_services_available'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(
                      service: _services[index],
                      isSmall: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              service: _services[index],
                              selectedMaster: widget.master,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Содержимое вкладки Портфолио
  Widget _buildPortfolioTab(BuildContext context) {
    if (widget.master.portfolio.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_portfolio_items'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.master.portfolio.length,
      itemBuilder: (context, index) {
        final imageUrl = widget.master.portfolio[index];
        return GestureDetector(
          onTap: () {
            // Открыть изображение на весь экран
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
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  // Содержимое вкладки Отзывы
  Widget _buildReviewsTab(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        // Виджет рейтинга
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Звезды
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.master.rating.floor()
                        ? Icons.star
                        : (index < widget.master.rating 
                            ? Icons.star_half
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 28,
                  );
                }),
              ),
              const SizedBox(width: 12),
              
              // Числовой рейтинг
              Text(
                widget.master.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              
              // Количество отзывов
              Text(
                '(${widget.master.reviewsCount} ${localizations.translate('reviews')})',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        
        // Кнопка "Смотреть все отзывы"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReviewsScreen(master: widget.master),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(localizations.translate('view_all_reviews')),
          ),
        ),
        
        // Кнопка "Оставить отзыв"
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateReviewScreen(master: widget.master),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(localizations.translate('leave_review')),
          ),
        ),
      ],
    );
  }
  
  // Содержимое вкладки Расписание
  Widget _buildScheduleTab(BuildContext context, AppLocalizations localizations) {
    // Получаем локализованные названия дней недели
    final weekDays = {
      'monday': localizations.translate('monday'),
      'tuesday': localizations.translate('tuesday'),
      'wednesday': localizations.translate('wednesday'),
      'thursday': localizations.translate('thursday'),
      'friday': localizations.translate('friday'),
      'saturday': localizations.translate('saturday'),
      'sunday': localizations.translate('sunday'),
    };
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final day = weekDays.keys.elementAt(index);
        final localizedDay = weekDays[day]!;
        final schedule = widget.master.schedule[day];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // День недели
                Expanded(
                  flex: 2,
                  child: Text(
                    localizedDay,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                
                // Расписание мастера на этот день
                Expanded(
                  flex: 3,
                  child: schedule == null
                      ? Text(
                          localizations.translate('day_off'),
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Рабочие часы
                            Text(
                              '${schedule.start} - ${schedule.end}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            // Перерывы
                            if (schedule.breaks.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                localizations.translate('breaks'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              ...schedule.breaks.map((breakTime) {
                                return Text(
                                  '${breakTime.start} - ${breakTime.end}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Класс для создания фиксированной табицы в SliverAppBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  
  _SliverAppBarDelegate(this._tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  
  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}