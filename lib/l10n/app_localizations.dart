// lib/l10n/app_localizations.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Вспомогательный метод для получения экземпляра AppLocalizations
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Делегат для локализации
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Словари с локализованными строками
  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      // Общие
      'app_name': 'Салон красоты Астана',
      'ok': 'ОК',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'delete': 'Удалить',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'success': 'Успешно',
      
      // Аутентификация
      'login': 'Вход',
      'register': 'Регистрация',
      'email': 'Email',
      'password': 'Пароль',
      'confirm_password': 'Подтвердите пароль',
      'name': 'Имя',
      'phone': 'Телефон',
      'forgot_password': 'Забыли пароль?',
      'no_account': 'Нет аккаунта?',
      'have_account': 'Уже есть аккаунт?',
      'signup_now': 'Зарегистрироваться',
      'login_now': 'Войти',
      'password_reset': 'Восстановление пароля',
      'password_reset_instructions': 'Введите ваш email, и мы отправим вам инструкции по восстановлению пароля.',
      'send_instructions': 'Отправить инструкции',
      'password_reset_sent': 'Инструкции по восстановлению пароля отправлены на ваш email.',
      
      // Главный экран
      'home': 'Главная',
      'services': 'Услуги',
      'appointments': 'Записи',
      'profile': 'Профиль',
      
      // Услуги
      'all_services': 'Все услуги',
      'popular_services': 'Популярные услуги',
      'search_services': 'Поиск услуг',
      'book_service': 'Записаться',
      'duration': 'Продолжительность',
      'price': 'Цена',
      'minutes': 'мин',
      
      // Мастера
      'masters': 'Мастера',
      'all_masters': 'Все мастера',
      'experience': 'Опыт работы',
      'specializations': 'Специализации',
      'portfolio': 'Портфолио',
      'reviews': 'Отзывы',
      
      // Записи
      'my_appointments': 'Мои записи',
      'upcoming': 'Предстоящие',
      'past': 'Прошедшие',
      'book_appointment': 'Записаться на прием',
      'cancel_appointment': 'Отменить запись',
      'reschedule': 'Перенести',
      'select_date': 'Выберите дату',
      'select_time': 'Выберите время',
      'select_master': 'Выберите мастера',
      'select_service': 'Выберите услугу',
      'confirm_booking': 'Подтвердить запись',
      'appointment_confirmed': 'Запись подтверждена',
      'appointment_cancelled': 'Запись отменена',
      'cancel_confirmation': 'Вы уверены, что хотите отменить запись?',
      'no_appointments': 'У вас нет записей',
      
      // Профиль
      'my_profile': 'Мой профиль',
      'edit_profile': 'Редактировать профиль',
      'language': 'Язык',
      'notifications': 'Уведомления',
      'push_notifications': 'Push-уведомления',
      'email_notifications': 'Email-уведомления',
      'sms_notifications': 'SMS-уведомления',
      'dark_mode': 'Темная тема',
      'logout': 'Выход',
      'loyalty_points': 'Бонусные баллы',
      'favorites': 'Избранное',
      
      // Программа лояльности
      'loyalty_program': 'Программа лояльности',
      'earned_points': 'Накопленные баллы',
      'points_history': 'История баллов',
      'points_usage': 'Использование баллов',
      'available_promotions': 'Доступные акции',
      
      // Отзывы
      'leave_review': 'Оставить отзыв',
      'rate_service': 'Оцените услугу',
      'write_review': 'Напишите отзыв',
      'upload_photo': 'Загрузить фото',
      'thank_for_review': 'Спасибо за ваш отзыв!',
      'no_reviews': 'Пока нет отзывов',
    },
    
    'kk': {
      // Общие
      'app_name': 'Астана сұлулық салоны',
      'ok': 'ОК',
      'cancel': 'Болдырмау',
      'save': 'Сақтау',
      'delete': 'Жою',
      'loading': 'Жүктелуде...',
      'error': 'Қате',
      'success': 'Сәтті',
      
      // Аутентификация
      'login': 'Кіру',
      'register': 'Тіркелу',
      'email': 'Email',
      'password': 'Құпия сөз',
      'confirm_password': 'Құпия сөзді растаңыз',
      'name': 'Аты',
      'phone': 'Телефон',
      'forgot_password': 'Құпия сөзді ұмыттыңыз ба?',
      'no_account': 'Тіркелгіңіз жоқ па?',
      'have_account': 'Тіркелгіңіз бар ма?',
      'signup_now': 'Тіркелу',
      'login_now': 'Кіру',
      'password_reset': 'Құпия сөзді қалпына келтіру',
      'password_reset_instructions': 'Email-ді енгізіңіз, біз сізге құпия сөзді қалпына келтіру нұсқауларын жібереміз.',
      'send_instructions': 'Нұсқауларды жіберу',
      'password_reset_sent': 'Құпия сөзді қалпына келтіру нұсқаулары сіздің email-ге жіберілді.',
      
      // Главный экран
      'home': 'Басты',
      'services': 'Қызметтер',
      'appointments': 'Жазылулар',
      'profile': 'Профиль',
      
      // Услуги
      'all_services': 'Барлық қызметтер',
      'popular_services': 'Танымал қызметтер',
      'search_services': 'Қызметтерді іздеу',
      'book_service': 'Жазылу',
      'duration': 'Ұзақтығы',
      'price': 'Бағасы',
      'minutes': 'мин',
      
      // Мастера
      'masters': 'Шеберлер',
      'all_masters': 'Барлық шеберлер',
      'experience': 'Жұмыс тәжірибесі',
      'specializations': 'Мамандандырулар',
      'portfolio': 'Портфолио',
      'reviews': 'Пікірлер',
      
      // Записи
      'my_appointments': 'Менің жазылуларым',
      'upcoming': 'Алдағы',
      'past': 'Өткен',
      'book_appointment': 'Жазылу',
      'cancel_appointment': 'Жазылуды болдырмау',
      'reschedule': 'Жазылуды ауыстыру',
      'select_date': 'Күнді таңдаңыз',
      'select_time': 'Уақытты таңдаңыз',
      'select_master': 'Шеберді таңдаңыз',
      'select_service': 'Қызметті таңдаңыз',
      'confirm_booking': 'Жазылуды растау',
      'appointment_confirmed': 'Жазылу расталды',
      'appointment_cancelled': 'Жазылу болдырылмады',
      'cancel_confirmation': 'Жазылуды болдырмау керек екеніне сенімдісіз бе?',
      'no_appointments': 'Сізде жазылулар жоқ',
      
      // Профиль
      'my_profile': 'Менің профилім',
      'edit_profile': 'Профильді өңдеу',
      'language': 'Тіл',
      'notifications': 'Хабарландырулар',
      'push_notifications': 'Push-хабарландырулар',
      'email_notifications': 'Email-хабарландырулар',
      'sms_notifications': 'SMS-хабарландырулар',
      'dark_mode': 'Қараңғы тақырып',
      'logout': 'Шығу',
      'loyalty_points': 'Бонустық ұпайлар',
      'favorites': 'Таңдаулылар',
      
      // Программа лояльности
      'loyalty_program': 'Адалдық бағдарламасы',
      'earned_points': 'Жинақталған ұпайлар',
      'points_history': 'Ұпайлар тарихы',
      'points_usage': 'Ұпайларды пайдалану',
      'available_promotions': 'Қолжетімді акциялар',
      
      // Отзывы
      'leave_review': 'Пікір қалдыру',
      'rate_service': 'Қызметті бағалау',
      'write_review': 'Пікір жазу',
      'upload_photo': 'Фото жүктеу',
      'thank_for_review': 'Пікіріңіз үшін рахмет!',
      'no_reviews': 'Әзірге пікірлер жоқ',
    },
    
    'en': {
      // General
      'app_name': 'Astana Beauty Salon',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Authentication
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'name': 'Name',
      'phone': 'Phone',
      'forgot_password': 'Forgot password?',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account?',
      'signup_now': 'Sign up',
      'login_now': 'Login',
      'password_reset': 'Password Reset',
      'password_reset_instructions': 'Enter your email and we will send you instructions to reset your password.',
      'send_instructions': 'Send Instructions',
      'password_reset_sent': 'Password reset instructions have been sent to your email.',
      
      // Main Screen
      'home': 'Home',
      'services': 'Services',
      'appointments': 'Appointments',
      'profile': 'Profile',
      
      // Services
      'all_services': 'All Services',
      'popular_services': 'Popular Services',
      'search_services': 'Search Services',
      'book_service': 'Book Service',
      'duration': 'Duration',
      'price': 'Price',
      'minutes': 'min',
      
      // Masters
      'masters': 'Masters',
      'all_masters': 'All Masters',
      'experience': 'Experience',
      'specializations': 'Specializations',
      'portfolio': 'Portfolio',
      'reviews': 'Reviews',
      
      // Appointments
      'my_appointments': 'My Appointments',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'book_appointment': 'Book Appointment',
      'cancel_appointment': 'Cancel Appointment',
      'reschedule': 'Reschedule',
      'select_date': 'Select Date',
      'select_time': 'Select Time',
      'select_master': 'Select Master',
      'select_service': 'Select Service',
      'confirm_booking': 'Confirm Booking',
      'appointment_confirmed': 'Appointment Confirmed',
      'appointment_cancelled': 'Appointment Cancelled',
      'cancel_confirmation': 'Are you sure you want to cancel this appointment?',
      'no_appointments': 'You have no appointments',
      
      // Profile
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'notifications': 'Notifications',
      'push_notifications': 'Push Notifications',
      'email_notifications': 'Email Notifications',
      'sms_notifications': 'SMS Notifications',
      'dark_mode': 'Dark Mode',
      'logout': 'Logout',
      'loyalty_points': 'Loyalty Points',
      'favorites': 'Favorites',
      
      // Loyalty Program
      'loyalty_program': 'Loyalty Program',
      'earned_points': 'Earned Points',
      'points_history': 'Points History',
      'points_usage': 'Points Usage',
      'available_promotions': 'Available Promotions',
      
      // Reviews
      'leave_review': 'Leave Review',
      'rate_service': 'Rate Service',
      'write_review': 'Write Review',
      'upload_photo': 'Upload Photo',
      'thank_for_review': 'Thank you for your review!',
      'no_reviews': 'No reviews yet',
    },
  };

  // Метод для получения локализованной строки
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['ru']?[key] ?? 
           key;
  }

  // Удобные геттеры для часто используемых строк
  String get appName => translate('app_name');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get haveAccount => translate('have_account');
  String get signupNow => translate('signup_now');
  String get loginNow => translate('login_now');
}

// Делегат для локализации
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ru', 'kk', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}