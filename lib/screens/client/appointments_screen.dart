// lib/screens/client/appointments_screen.dart

import 'package:beauty_salon_app/screens/client/services_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../services/auth_service.dart';
import '../../services/appointments_service.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

// Глобальный ключ для доступа к состоянию экрана из других мест
final GlobalKey<AppointmentsScreenState> appointmentsScreenKey = GlobalKey<AppointmentsScreenState>();

class AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _pastAppointments = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadAppointments();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Загрузка записей пользователя (публичный метод для возможности вызова извне)
  Future<void> loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUserModel;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final appointmentsService = AppointmentsService();
      
      // Загрузка предстоящих записей
      final upcomingAppointments = await appointmentsService.getUpcomingAppointments(user.id);
      
      // Загрузка прошедших записей
      final pastAppointments = await appointmentsService.getPastAppointments(user.id);
      
      if (mounted) {
        setState(() {
          _upcomingAppointments = upcomingAppointments;
          _pastAppointments = pastAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке записей: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке записей: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Отмена записи
  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    // Подтверждение отмены
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('cancel_appointment')),
        content: Text(AppLocalizations.of(context).translate('cancel_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).translate('ok')),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointmentsService = AppointmentsService();
      final success = await appointmentsService.cancelAppointment(appointment.id);
      
      if (success) {
        // Обновляем список записей
        loadAppointments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('appointment_cancelled')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      debugPrint('Ошибка при отмене записи: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при отмене записи: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('my_appointments')),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.translate('upcoming')),
            Tab(text: localizations.translate('past')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Предстоящие записи
                _upcomingAppointments.isEmpty
                    ? _buildEmptyState(localizations.translate('no_upcoming_appointments'))
                    : _buildAppointmentsList(_upcomingAppointments, canCancel: true),
                
                // Прошедшие записи
                _pastAppointments.isEmpty
                    ? _buildEmptyState(localizations.translate('no_past_appointments'))
                    : _buildAppointmentsList(_pastAppointments),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Переход на экран выбора услуги
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ServicesScreen(isForBooking: true),
            ),
          ).then((result) {
            // Если вернулись с результатом true, обновляем список записей
            if (result == true) {
              loadAppointments();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Состояние, когда нет записей
  Widget _buildEmptyState(String message) {
    return RefreshIndicator(
      onRefresh: loadAppointments,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Список записей
  Widget _buildAppointmentsList(List<AppointmentModel> appointments, {bool canCancel = false}) {
    return RefreshIndicator(
      onRefresh: loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            onTap: () {
              // Просмотр деталей записи (можно добавить в будущем)
            },
            onCancel: canCancel && appointment.canBeCancelled
                ? () => _cancelAppointment(appointment)
                : null,
          );
        },
      ),
    );
  }
}