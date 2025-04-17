// lib/screens/admin/admin_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/appointment_model.dart';
import '../../services/appointments_service.dart';
import '../../widgets/loading_overlay.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  bool _isLoading = true;
  List<AppointmentModel> _appointments = [];
  DateTime _selectedDay = DateTime.now();
  final AppointmentsService _appointmentsService = AppointmentsService();

  @override
  void initState() {
    super.initState();
    _loadAppointmentsForDate(_selectedDay);
  }

  // Загрузка записей на выбранную дату
  Future<void> _loadAppointmentsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Вызов нового метода в AppointmentsService для получения всех записей на дату
      final appointments = await _appointmentsService.getAppointmentsForDate(date);
      
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке записей: $e');
      
      setState(() {
        _isLoading = false;
        _appointments = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке записей: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Отмена записи
  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    // Подтверждение отмены
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отмена записи'),
        content: const Text('Вы уверены, что хотите отменить запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await _appointmentsService.cancelAppointment(appointment.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запись успешно отменена'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Перезагрузка записей
        _loadAppointmentsForDate(_selectedDay);
      } else {
        throw Exception('Не удалось отменить запись');
      }
    } catch (e) {
      debugPrint('Ошибка при отмене записи: $e');
      
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

  // Изменение статуса записи
  Future<void> _changeAppointmentStatus(AppointmentModel appointment, String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Реализуйте метод в AppointmentsService для изменения статуса
      final success = await _appointmentsService.updateAppointmentStatus(
        appointment.id, 
        newStatus
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Статус записи успешно изменен'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Перезагрузка записей
        _loadAppointmentsForDate(_selectedDay);
      } else {
        throw Exception('Не удалось изменить статус записи');
      }
    } catch (e) {
      debugPrint('Ошибка при изменении статуса записи: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при изменении статуса: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: Column(
          children: [
            // Календарь
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
                _loadAppointmentsForDate(selectedDay);
              },
              calendarFormat: CalendarFormat.week,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const Divider(),
            
            // Список записей
            Expanded(
              child: _appointments.isEmpty
                ? const Center(
                    child: Text('Нет записей на выбранную дату'),
                  )
                : ListView.builder(
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      return _buildAppointmentCard(appointment);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Карточка записи
  Widget _buildAppointmentCard(AppointmentModel appointment) {
    // Определяем цвет карточки в зависимости от статуса
    Color statusColor;
    String statusText;
    
    switch (appointment.status) {
      case 'booked':
        statusColor = Colors.blue;
        statusText = 'Забронировано';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Завершено';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Отменено';
        break;
      case 'no-show':
        statusColor = Colors.orange;
        statusText = 'Неявка';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Неизвестно';
    }
    
    // Форматирование даты
    final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(appointment.date);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и статус
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Информация о клиенте и мастере
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Клиент:'),
                const SizedBox(width: 4),
                // Здесь должно быть имя клиента, но оно не входит в модель AppointmentModel
                Text(appointment.clientId),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Мастер:'),
                const SizedBox(width: 4),
                Text(appointment.masterName),
              ],
            ),
            const SizedBox(height: 4),
            
            // Дата и время
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$formattedDate, ${appointment.startTime} - ${appointment.endTime}'),
              ],
            ),
            const SizedBox(height: 4),
            
            // Цена
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${appointment.price} ₸'),
              ],
            ),
            
            // Примечания
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(appointment.notes!),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Кнопки в зависимости от статуса
                if (appointment.status == 'booked') ...[
                  // Кнопка отметки как "Завершено"
                  IconButton(
                    onPressed: () => _changeAppointmentStatus(appointment, 'completed'),
                    icon: const Icon(Icons.check_circle_outline),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.green),
                      ),
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Кнопка отметки как "Неявка"
                  IconButton(
                    onPressed: () => _changeAppointmentStatus(appointment, 'no-show'),
                    icon: const Icon(Icons.person_off_outlined),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.orange),
                      ),
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Кнопка отмены
                  IconButton(
                    onPressed: () => _cancelAppointment(appointment),
                    icon: const Icon(Icons.cancel_outlined),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red),
                      ),
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}