// lib/screens/client/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../widgets/loading_overlay.dart';
import '../auth/login_screen.dart';
import 'my_reviews_screen.dart'; // Импортируем экран моих отзывов
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  // Выход из аккаунта
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
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

  // Изменение языка приложения
  Future<void> _changeLanguage(BuildContext context) async {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Русский язык
              ListTile(
                title: const Text('Русский'),
                leading: Radio<String>(
                  value: 'ru',
                  groupValue: languageService.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      languageService.setLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  languageService.setLanguage('ru');
                  Navigator.of(context).pop();
                },
              ),
              
              // Казахский язык
              ListTile(
                title: const Text('Қазақша'),
                leading: Radio<String>(
                  value: 'kk',
                  groupValue: languageService.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      languageService.setLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  languageService.setLanguage('kk');
                  Navigator.of(context).pop();
                },
              ),
              
              // Английский язык
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: languageService.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      languageService.setLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  languageService.setLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.myProfile),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Верхняя секция с аватаром и именем
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Аватар
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Имя пользователя
                        Text(
                          user?.displayName ?? '',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        
                        // Email
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        
                        // Телефон
                        Text(
                          user?.phoneNumber ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        
                        // Бонусные баллы
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${user?.loyaltyPoints ?? 0} ${localizations.loyaltyPoints}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Кнопка редактирования профиля
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Text(localizations.editProfile),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Секция управления аккаунтом
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('account_management'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        // Мои отзывы - добавляем новую опцию
                        ListTile(
                          leading: const Icon(Icons.rate_review),
                          title: Text(localizations.translate('my_reviews')),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyReviewsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        
                        // Моя программа лояльности
                        ListTile(
                          leading: const Icon(Icons.card_giftcard),
                          title: Text(localizations.translate('loyalty_program')),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Переход на экран программы лояльности
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Настройки
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('settings'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        // Язык
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(localizations.language),
                          subtitle: Text(
                            Provider.of<LanguageService>(context).currentLanguageName,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _changeLanguage(context),
                        ),
                        const Divider(),
                        
                        // Уведомления
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: Text(localizations.notifications),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Реализовать экран настроек уведомлений
                          },
                        ),
                        const Divider(),
                        
                        // Тёмная тема
                        ListTile(
                          leading: const Icon(Icons.dark_mode),
                          title: Text(localizations.darkMode),
                          trailing: Switch(
                            value: Theme.of(context).brightness == Brightness.dark,
                            onChanged: (value) {
                              // TODO: Реализовать переключение темы
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Кнопка выхода
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations.logout),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}