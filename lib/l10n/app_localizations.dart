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
      'no_services_found': 'Услуги не найдены',
      'description': 'Описание',
      'available_masters': 'Доступные мастера',
      'no_available_masters': 'Нет доступных мастеров',
      
      // Мастера
      'masters': 'Мастера',
      'all_masters': 'Все мастера',
      'experience': 'Опыт работы',
      'specializations': 'Специализации',
      'portfolio': 'Портфолио',
      'reviews': 'Отзывы',
      'no_masters_found': 'Мастера не найдены',
      'about_master': 'О мастере',
      'book_with_master': 'Записаться к мастеру',
      'no_portfolio_items': 'Нет элементов портфолио',
      'about': 'О мастере',
      'schedule': 'Расписание',
      'day_off': 'Выходной',
      'breaks': 'Перерывы',
      'search_masters': 'Поиск мастеров',
      'all': 'Все',
      
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
      'no_upcoming_appointments': 'У вас нет предстоящих записей',
      'no_past_appointments': 'У вас нет прошедших записей',
      'notes': 'Заметки',
      'notes_hint': 'Добавьте комментарий или пожелания к записи',
      'please_select_all_fields': 'Пожалуйста, заполните все поля',
      'no_available_times': 'Нет доступного времени для записи',
      'selected_service': 'Выбранная услуга',
      'booked': 'Забронировано',
      'completed': 'Завершено',
      'cancelled': 'Отменено',
      'no-show': 'Неявка',
      
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
      'settings': 'Настройки',
      'profile_updated': 'Профиль обновлен',
      
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

      // Дни недели
      'monday': 'Понедельник',
      'tuesday': 'Вторник',
      'wednesday': 'Среда',
      'thursday': 'Четверг',
      'friday': 'Пятница',
      'saturday': 'Суббота',
      'sunday': 'Воскресенье',

      // Дополнительные строки
      'no_services_available': 'Нет доступных услуг',

    },
    
    // Вставьте здесь такие же строки для казахского и английского языков...
    'kk': {
      // Общие
      'app_name': 'Астана сұлулық салоны',
      'ok': 'OK',
      // ... и так далее
    },
    
    'en': {
      // Общие
      'app_name': 'Astana Beauty Salon',
      'ok': 'OK',
      // ... и так далее
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
  
  // Добавьте недостающие геттеры
  String get passwordReset => translate('password_reset');
  String get passwordResetInstructions => translate('password_reset_instructions');
  String get sendInstructions => translate('send_instructions');
  String get passwordResetSent => translate('password_reset_sent');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  
  // Главный экран
  String get home => translate('home');
  String get services => translate('services');
  String get appointments => translate('appointments');
  String get profile => translate('profile');
  
  // Услуги
  String get allServices => translate('all_services');
  String get popularServices => translate('popular_services');
  String get searchServices => translate('search_services');
  String get bookService => translate('book_service');
  String get duration => translate('duration');
  String get price => translate('price');
  String get minutes => translate('minutes');
  String get noServicesFound => translate('no_services_found');
  String get description => translate('description');
  String get availableMasters => translate('available_masters');
  String get noAvailableMasters => translate('no_available_masters');
  
  // Мастера
  String get masters => translate('masters');
  String get allMasters => translate('all_masters');
  String get aboutMaster => translate('about_master');
  String get noMastersFound => translate('no_masters_found');
  String get about => translate('about');
  String get portfolio => translate('portfolio');
  String get schedule => translate('schedule');
  
  // Записи
  String get myAppointments => translate('my_appointments');
  String get upcoming => translate('upcoming');
  String get past => translate('past');
  String get bookAppointment => translate('book_appointment');
  String get cancelAppointment => translate('cancel_appointment');
  String get selectDate => translate('select_date');
  String get selectTime => translate('select_time');
  String get selectMaster => translate('select_master');
  String get selectService => translate('select_service');
  String get confirmBooking => translate('confirm_booking');
  String get appointmentConfirmed => translate('appointment_confirmed');
  String get noAppointments => translate('no_appointments');
  String get noUpcomingAppointments => translate('no_upcoming_appointments');
  String get noPastAppointments => translate('no_past_appointments');
  String get pleaseSelectAllFields => translate('please_select_all_fields');
  String get noAvailableTimes => translate('no_available_times');
  String get selectedService => translate('selected_service');
  
  // Профиль
  String get myProfile => translate('my_profile');
  String get editProfile => translate('edit_profile');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get darkMode => translate('dark_mode');
  String get logout => translate('logout');
  String get loyaltyPoints => translate('loyalty_points');
  String get settings => translate('settings');
  String get profileUpdated => translate('profile_updated');
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