// lib/screens/client/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../models/service_model.dart';
import '../../models/master_model.dart';
import '../../models/appointment_model.dart';
import '../../widgets/service_card.dart';
import '../../widgets/master_card.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/promotions_slider.dart';
import '../../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<ServiceModel> _popularServices = [];
  List<MasterModel> _topMasters = [];
  List<AppointmentModel> _upcomingAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Загрузка данных для дашборда
  Future<void> _loadData() async {
    // TODO: Реализовать загрузку данных из Firebase
    // На данном этапе используем заглушки для тестирования

    // Имитация задержки загрузки данных
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appName),
        automaticallyImplyLeading: false, // Убираем кнопку "назад"
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(localizations, authService),
    );
  }

  Widget _buildDashboardContent(AppLocalizations localizations, AuthService authService) {
    final userName = authService.currentUserModel?.displayName ?? '';
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            Text(
              '${_getGreeting()}, $userName!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            
            // Баннер акций
            const PromotionsSlider(),
            const SizedBox(height: 24),
            
            // Ближайшие записи
            if (_upcomingAppointments.isNotEmpty) ...[
              _sectionHeader(localizations.myAppointments),
              _buildAppointmentList(),
              const SizedBox(height: 24),
            ],
            
            // Популярные услуги
            _sectionHeader(localizations.popularServices),
            _buildServicesPlaceholder(),
            const SizedBox(height: 24),
            
            // Топ мастеров
            _sectionHeader(localizations.masters),
            _buildMastersPlaceholder(),
          ],
        ),
      ),
    );
  }

  // Подбор приветствия в зависимости от времени суток
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return 'Доброй ночи';
    } else if (hour < 12) {
      return 'Доброе утро';
    } else if (hour < 18) {
      return 'Добрый день';
    } else {
      return 'Добрый вечер';
    }
  }

  // Заголовок раздела
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  // Список популярных услуг (заглушка)
  Widget _buildServicesPlaceholder() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Заглушка для 5 услуг
        itemBuilder: (context, index) {
          return Container(
            width: 150,
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

  // Список мастеров (заглушка)
  Widget _buildMastersPlaceholder() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Заглушка для 5 мастеров
        itemBuilder: (context, index) {
          return Container(
            width: 130,
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

  // Список предстоящих записей
  Widget _buildAppointmentList() {
    if (_upcomingAppointments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.spa,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 18,
                            width: 120,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 100,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Container(
                      height: 14,
                      width: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 8),
                    Container(
                      height: 14,
                      width: 60,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}