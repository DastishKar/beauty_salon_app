// lib/screens/client/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/notifications_service.dart';
import '../../widgets/loading_overlay.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService _notificationsService = NotificationsService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUserModel;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Загрузка уведомлений
      final notifications = await _notificationsService.getUserNotifications(user.id);
      
      // Отметка всех уведомлений как прочитанных
      await _notificationsService.markAllAsRead(user.id);

      if (mounted) {
        setState(() {
          _notifications = notifications.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке уведомлений: $e'),
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

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('notifications')),
          actions: [
            // Кнопка очистки всех уведомлений
            if (_notifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () async {
                  // Запрос подтверждения удаления
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(localizations.translate('clear_all_notifications')),
                      content: Text(localizations.translate('clear_notifications_confirmation')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(localizations.translate('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(localizations.translate('clear')),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final user = authService.currentUserModel;

                      if (user == null) {
                        throw Exception('User not authenticated');
                      }

                      // Удаление всех уведомлений
                      await _notificationsService.deleteAllNotifications(user.id);
                      
                      if (mounted) {
                        setState(() {
                          _notifications = [];
                          _isLoading = false;
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.translate('notifications_cleared')),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ошибка при очистке уведомлений: $e'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
          ],
        ),
        body: _notifications.isEmpty
            ? _buildEmptyState(context, localizations)
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(context, notification);
                  },
                ),
              ),
      ),
    );
  }
  
  // Отображение при отсутствии уведомлений
  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('no_notifications'),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Элемент уведомления
  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification) {
    // Форматирование даты
    final DateTime? createdAt = notification['createdAt'] != null
        ? (notification['createdAt'] is DateTime
            ? notification['createdAt']
            : DateTime.fromMillisecondsSinceEpoch(notification['createdAt']))
        : null;
    
    final formattedDate = createdAt != null
        ? '${createdAt.day}.${createdAt.month}.${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
        : '';
    
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) async {
        try {
          // Удаление уведомления
          await _notificationsService.deleteNotification(notification['id']);
          
          if (mounted) {
            setState(() {
              _notifications.removeWhere((item) => item['id'] == notification['id']);
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Уведомление удалено'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка при удалении уведомления: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и дата
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Сообщение
              Text(notification['message'] ?? ''),
              
              // Если есть ссылка на запись, добавляем кнопку для перехода
              if (notification['appointmentId'] != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Добавить переход к деталям записи
                    },
                    child: Text('Перейти к записи'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}