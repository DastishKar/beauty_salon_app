// lib/screens/client/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _pastAppointments = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Загрузка записей пользователя
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Реализовать загрузку записей из Firestore
    // Пока используем заглушку
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
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
                    : _buildAppointmentsList(_upcomingAppointments),
                
                // Прошедшие записи
                _pastAppointments.isEmpty
                    ? _buildEmptyState(localizations.translate('no_past_appointments'))
                    : _buildAppointmentsList(_pastAppointments),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Переход на экран создания записи
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => BookingScreen(),
          //   ),
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Состояние, когда нет записей
  Widget _buildEmptyState(String message) {
    return Center(
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
    );
  }

  // Список записей
  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        // TODO: Заменить на настоящую карточку, когда будет готова
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text('Запись #${index + 1}'),
            subtitle: Text('Заглушка для записи'),
          ),
        );
        // return AppointmentCard(
        //   appointment: appointments[index],
        //   onTap: () {
        //     // Действие при нажатии на карточку
        //   },
        // );
      },
    );
  }
}