// lib/screens/client/dashboard_screen.dart

import 'package:beauty_salon_app/screens/client/appointments_screen.dart';
import 'package:beauty_salon_app/screens/client/master_details_screen.dart';
import 'package:beauty_salon_app/screens/client/notification_screen.dart';
import 'package:beauty_salon_app/screens/client/service_details_screen.dart';
import 'package:beauty_salon_app/services/appointments_service.dart';
import 'package:beauty_salon_app/widgets/promotions_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../models/appointment_model.dart';
import '../../services/masters_service.dart';
import '../../services/services_service.dart';
import '../../models/service_model.dart';
import '../../models/master_model.dart';
import '../../widgets/service_card.dart';
import '../../widgets/master_card.dart';
import 'services_screen.dart';
import 'masters_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<AppointmentModel> _upcomingAppointments = [];
  List<ServiceModel> _popularServices = [];
  List<MasterModel> _topMasters = [];
  int _loyaltyPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Загрузка данных для дашборда
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUserModel;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Загрузка ближайших записей
      final appointmentsService = AppointmentsService();
      final upcomingAppointments = await appointmentsService.getUpcomingAppointments(user.id);
      
      // Загрузка популярных услуг
      final servicesService = ServicesService();
      final popularServices = await servicesService.getPopularServices(limit: 5);
      
      // Загрузка топовых мастеров
      final mastersService = MastersService();
      final topMasters = await mastersService.getAllMasters();
      topMasters.sort((a, b) => b.rating.compareTo(a.rating)); // Сортировка по рейтингу
      
      // Получаем баллы лояльности
      _loyaltyPoints = user.loyaltyPoints;
      
      if (mounted) {
        setState(() {
          _upcomingAppointments = upcomingAppointments;
          _popularServices = popularServices;
          _topMasters = topMasters.take(5).toList(); // Берем только 5 лучших мастеров
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке данных: $e');
      
      // В случае ошибки, все равно завершаем загрузку
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context);
    final languageCode = Provider.of<LanguageService>(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appName),
        automaticallyImplyLeading: false, // Убираем кнопку "назад"
        actions: [
          // Кнопка уведомлений
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Приветствие
                    _buildGreeting(authService),
                    const SizedBox(height: 24),
                    
                    // Баннер акций
                    const PromotionsSlider(),
                    const SizedBox(height: 24),
                    
                    // Ближайшие записи
                    if (_upcomingAppointments.isNotEmpty) ...[
                      _sectionHeader(
                        localizations.myAppointments,
                        onViewAll: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AppointmentsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildAppointmentsList(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Популярные услуги
                    _sectionHeader(
                      localizations.popularServices,
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ServicesScreen(),
                          ),
                        );
                      },
                    ),
                    _popularServices.isEmpty
                        ? _buildServicesPlaceholder()
                        : _buildServicesList(languageCode),
                    const SizedBox(height: 24),
                    
                    // Топ мастеров
                    _sectionHeader(
                      localizations.translate('top_masters'),
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MastersScreen(),
                          ),
                        );
                      },
                    ),
                    _topMasters.isEmpty
                        ? _buildMastersPlaceholder()
                        : _buildMastersList(),
                  ],
                ),
              ),
            ),
    );
  }

  // Приветствие пользователя
  Widget _buildGreeting(AuthService authService) {
    final userName = authService.currentUserModel?.displayName.split(' ').first ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()}, $userName!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).translate('dashboard_tagline'),
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Заголовок раздела с кнопкой "Смотреть все"
  Widget _sectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(AppLocalizations.of(context).translate('view_all')),
            ),
        ],
      ),
    );
  }

  // Список популярных услуг
  Widget _buildServicesList(String languageCode) {
    return SizedBox(
      height: 250, // Увеличенная высота для полного отображения карточек
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularServices.length,
        itemBuilder: (context, index) {
          final service = _popularServices[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 160, // Увеличенная ширина для полного отображения карточек
              child: ServiceCard(
                service: service,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailsScreen(service: service),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Список мастеров
  Widget _buildMastersList() {
    return SizedBox(
      height: 270, // Увеличенная высота для полного отображения карточек
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topMasters.length,
        itemBuilder: (context, index) {
          final master = _topMasters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 140, // Увеличенная ширина для полного отображения карточек
              child: MasterCard(
                master: master,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MasterDetailsScreen(master: master),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Список предстоящих записей
  Widget _buildAppointmentsList() {
    if (_upcomingAppointments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _upcomingAppointments.length > 3 ? 3 : _upcomingAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _upcomingAppointments[index];
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Переход к деталям записи
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название услуги
                      Text(
                        appointment.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Мастер
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appointment.masterName,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Дата и время
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${appointment.date.day}.${appointment.date.month}.${appointment.date.year}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            appointment.startTime,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Цена
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${appointment.price} ₸',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Заглушка для услуг (используется, если нет данных)
  Widget _buildServicesPlaceholder() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Заглушка для 5 услуг
        itemBuilder: (context, index) {
          return Container(
            width: 160, // Увеличенная ширина для соответствия реальным карточкам
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.spa,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 60,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Заглушка для мастеров (используется, если нет данных)
  Widget _buildMastersPlaceholder() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Заглушка для 5 мастеров
        itemBuilder: (context, index) {
          return Container(
            width: 140, // Увеличенная ширина для соответствия реальным карточкам
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 60,
                  color: Colors.grey[300],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Подбор приветствия в зависимости от времени суток
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return AppLocalizations.of(context).translate('good_night');
    } else if (hour < 12) {
      return AppLocalizations.of(context).translate('good_morning');
    } else if (hour < 18) {
      return AppLocalizations.of(context).translate('good_afternoon');
    } else {
      return AppLocalizations.of(context).translate('good_evening');
    }
  }
}