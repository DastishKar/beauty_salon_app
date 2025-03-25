// lib/screens/client/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../l10n/app_localizations.dart';
import '../../models/service_model.dart';
import '../../models/master_model.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../widgets/loading_overlay.dart';


class BookingScreen extends StatefulWidget {
  final ServiceModel service;
  final MasterModel? selectedMaster;

  const BookingScreen({
    super.key,
    required this.service,
    this.selectedMaster,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  DateTime _selectedDay = DateTime.now();
  MasterModel? _selectedMaster;
  String? _selectedTime;
  final List<MasterModel> _availableMasters = [];
  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _selectedMaster = widget.selectedMaster;
    _loadMasters();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Загрузка доступных мастеров
  Future<void> _loadMasters() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Реализовать загрузку мастеров из Firestore
    // Пока используем заглушку
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      // После выбора мастера нужно загрузить доступное время
      _loadAvailableTimes();
    });
  }

  // Загрузка доступного времени для записи
  Future<void> _loadAvailableTimes() async {
    setState(() {
      _isLoading = true;
      _selectedTime = null;
    });
    
    // TODO: Реализовать загрузку доступного времени из Firestore
    // Пока используем заглушку со временем с 9:00 до 18:00 с шагом 30 минут
    await Future.delayed(const Duration(seconds: 1));
    
    final List<String> times = [];
    final DateTime startTime = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 9, 0);
    final DateTime endTime = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 18, 0);
    
    DateTime currentTime = startTime;
    while (currentTime.isBefore(endTime)) {
      times.add(
        '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}'
      );
      currentTime = currentTime.add(const Duration(minutes: 30));
    }
    
    setState(() {
      _availableTimes = times;
      _isLoading = false;
    });
  }

  // Создание записи
  Future<void> _createBooking() async {
    if (_selectedMaster == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('please_select_all_fields')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUserModel;
      
      if (user == null) throw Exception('User not authenticated');
      
      // Расчет времени окончания услуги
      final startTimeParts = _selectedTime!.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      
      final startDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        startHour,
        startMinute,
      );
      
      startDateTime.add(Duration(minutes: widget.service.duration));
      
      // TODO: Создание записи в Firestore
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('appointment_confirmed')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Возвращаем true, чтобы обновить список записей
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
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
    final languageCode = Provider.of<LanguageService>(context).languageCode;
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('book_appointment')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация о выбранной услуге
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('selected_service'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.spa,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.service.getLocalizedName(languageCode),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${widget.service.price} ₸',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.service.duration} мин',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Выбор даты
                Text(
                  localizations.translate('select_date'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _selectedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                      _loadAvailableTimes();
                    },
                    calendarFormat: CalendarFormat.twoWeeks,
                    availableCalendarFormats: const {
                      CalendarFormat.twoWeeks: 'Две недели',
                      CalendarFormat.month: 'Месяц',
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha((0.3*255).round()),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Выбор мастера
                Text(
                  localizations.translate('select_master'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_availableMasters.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          localizations.translate('no_available_masters'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableMasters.length,
                      itemBuilder: (context, index) {
                        final master = _availableMasters[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMaster = master;
                              });
                              _loadAvailableTimes();
                            },
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedMaster?.id == master.id
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                                    backgroundImage: master.photoURL != null
                                        ? NetworkImage(master.photoURL!)
                                        : null,
                                    child: master.photoURL == null
                                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    master.displayName,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Выбор времени
                Text(
                  localizations.translate('select_time'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _availableTimes.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              localizations.translate('no_available_times'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableTimes.map((time) {
                          final isSelected = time == _selectedTime;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTime = time;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),
                
                // Поле для заметок
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('notes'),
                    hintText: localizations.translate('notes_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                // Кнопка подтверждения записи
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createBooking,
                    child: Text(localizations.translate('confirm_booking')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}