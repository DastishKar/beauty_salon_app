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
      'gallery': 'Галерея',
      'camera': 'Камера',
      'select_image_source': 'Выберите источник изображения',
      'theme': 'Тема',
      'light_theme': 'Светлая тема',
      'dark_theme': 'Темная тема',
      'system_theme': 'Системная тема',
      
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

      // Существующие строки...
      'view_all': 'Смотреть все',
      'dashboard_tagline': 'Преобразите себя с нами',
      'good_morning': 'Доброе утро',
      'good_afternoon': 'Добрый день',
      'good_evening': 'Добрый вечер',
      'good_night': 'Доброй ночи',
      'top_masters': 'Топ мастеров',
      'no_notifications': 'У вас нет уведомлений',
      'clear_all_notifications': 'Очистить все уведомления',
      'clear_notifications_confirmation': 'Вы уверены, что хотите удалить все уведомления?',
      'clear': 'Очистить',
      'notifications_cleared': 'Уведомления очищены',
      
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
      'available_promotions': 'Доступные акции',
      'my_promotions': 'Мои акции',
      'no_points_history': 'У вас пока нет истории баллов',
      'no_available_promotions': 'Доступных акций пока нет',
      'no_redeemed_promotions': 'У вас нет использованных акций',
      'redeem': 'Использовать',
      'points': 'баллов',
      'valid_until': 'Действует до',
      'not_enough_points': 'Недостаточно баллов',
      'redeem_promotion': 'Использование акции',
      'confirm_redeem_promotion': 'Вы действительно хотите использовать акцию',
      'for': 'за',
      'confirm': 'Подтвердить',
      'promotion_redeemed': 'Акция успешно использована',
      'loyalty_level_basic': 'Базовый уровень',
      'loyalty_level_silver': 'Серебряный уровень',
      'loyalty_level_gold': 'Золотой уровень',
      'loyalty_level_platinum': 'Платиновый уровень',
      'points_earning_rule': 'Вы получаете 1 балл за каждые 100 тенге в вашем заказе',
      'use_promotion': 'Использовать акцию',
      'redeemed_on': 'Получено',
      'show_to_salon_staff': 'Покажите этот код администратору салона',
      'close': 'Закрыть',
      
      // Отзывы
      'leave_review': 'Оставить отзыв',
      'rate_service': 'Оцените услугу',
      'write_review': 'Напишите отзыв',
      'upload_photo': 'Загрузить фото',
      'thank_for_review': 'Спасибо за ваш отзыв!',
      'no_reviews': 'Пока нет отзывов',
      'delete_review': 'Удалить отзыв',
      'delete_review_confirmation': 'Вы уверены, что хотите удалить отзыв?',
      'review_deleted': 'Отзыв удален',
      'view_all_reviews': 'Смотреть все отзывы',
      'send_review': 'Отправить отзыв',
      'review_hint': 'Напишите ваше мнение о работе мастера...',
      'review_required': 'Пожалуйста, напишите отзыв',
      'add_photo': 'Добавить фото',
      'max_photos_reached': 'Достигнут лимит фото',
      'max_photos_warning': 'Можно загрузить максимум 5 фотографий',
      'photo_limit': 'Фотографий',
      'not_authenticated': 'Вы не авторизованы',
      'select_appointment': 'Выберите запись',

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
      'my_reviews': 'Мои отзывы',
      'no_reviews_yet': 'У вас пока нет отзывов',
      'account_management': 'Управление аккаунтом',

      // Аналитика
      'analytics': 'Аналитика',
      'overview': 'Обзор',
      'total_appointments': 'Всего записей',
      'total_revenue': 'Общий доход',
      'completion_rate': 'Процент завершения',
      'revenue_trend': 'Тренд выручки',
      'appointment_status': 'Статус записей',
      'popular_services': 'Популярные услуги',
      'services_performance': 'Статистика услуг',
      'masters_performance': 'Статистика мастеров',
      'top_masters': 'Топ мастеров',
      'service': 'Услуга',
      'master': 'Мастер',
      'appointments': 'Записи',
      'completed': 'Завершено',
      'cancelled': 'Отменено',
      'revenue': 'Выручка',
      'no_data_available': 'Нет данных',
      'select_period': 'Выберите период',
      'last_week': 'Неделя',
      'last_month': 'Месяц',
      'last_year': 'Год',
      'custom': 'Другой период',
    },
    
    // Для казахского языка
    'kk': {
      // Общие
      'app_name': 'Астана сұлулық салоны',
      'ok': 'OK',
      'my_reviews': 'Менің пікірлерім',
      'no_reviews_yet': 'Сізде әлі пікірлер жоқ',
      'account_management': 'Тіркелгіні басқару',
      'loyalty_program': 'Адалдық бағдарламасы',
      'earned_points': 'Жинақталған ұпайлар',
      'points_history': 'Ұпайлар тарихы',
      'points_usage': 'Ұпайларды пайдалану',
      'available_promotions': 'Қол жетімді акциялар',
      'no_points_history': 'Сізде әлі ұпайлар тарихы жоқ',
      'no_available_promotions': 'Қол жетімді акциялар жоқ',
      'redeem': 'Қолдану',
      'points': 'ұпай',
      'valid_until': 'Жарамдылық мерзімі',
      'not_enough_points': 'Ұпай жеткіліксіз',
      'redeem_promotion': 'Акцияны қолдану',
      'confirm_redeem_promotion': 'Сіз шынымен акцияны пайдаланғыңыз келе ме',
      'for': 'үшін',
      'confirm': 'Растау',
      'promotion_redeemed': 'Акция сәтті пайдаланылды',
      'loyalty_level_basic': 'Негізгі деңгей',
      'loyalty_level_silver': 'Күміс деңгейі (5% жеңілдік)',
      'loyalty_level_gold': 'Алтын деңгейі (10% жеңілдік)',
      'loyalty_level_platinum': 'Платина деңгейі (15% жеңілдік)',
      'earn_points_hint': 'Әр жазбамен ұпай жинап, оларды жеңілдіктер мен арнайы ұсыныстарға айырбастаңыз',
      'points_earning_rule': 'Сіз тапсырысыңыздағы әрбір 100 теңге үшін 1 ұпай аласыз',

      // Auth
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
      'signup_now': 'Қазір тіркелу',
      'login_now': 'Кіру',
      'password_reset': 'Құпия сөзді қалпына келтіру',
      'password_reset_instructions': 'Нұсқауларды алу үшін email енгізіңіз',
      'send_instructions': 'Нұсқауларды жіберу',
      'password_reset_sent': 'Нұсқаулар жіберілді',

      // Navigation
      'home': 'Басты бет',
      'services': 'Қызметтер',
      'appointments': 'Жазбалар',
      'profile': 'Профиль',

      // Services
      'all_services': 'Барлық қызметтер',
      'search_services': 'Қызметтерді іздеу',
      'book_service': 'Жазылу',
      'duration': 'Ұзақтығы',
      'price': 'Бағасы',
      'minutes': 'мин',
      'no_services_found': 'Қызметтер табылмады',
      'description': 'Сипаттама',
      'available_masters': 'Қол жетімді шеберлер',

      // Masters
      'masters': 'Шеберлер',
      'experience': 'Тәжірибе',
      'specializations': 'Мамандандырулар',
      'portfolio': 'Портфолио',
      'reviews': 'Пікірлер',
      'about_master': 'Шебер туралы',
      'book_with_master': 'Шеберге жазылу',
      'no_portfolio_items': 'Портфолио бос',
      'schedule': 'Кесте',
      'day_off': 'Демалыс',
      'breaks': 'Үзілістер',

      // Reviews
      'leave_review': 'Пікір қалдыру',
      'rate_service': 'Қызметті бағалаңыз',
      'write_review': 'Пікір жазыңыз',
      'upload_photo': 'Фото жүктеу',
      'thank_for_review': 'Пікіріңіз үшін рахмет!',
      'no_reviews': 'Пікірлер жоқ',
      'delete_review': 'Пікірді жою',
      'delete_review_confirmation': 'Пікірді жойғыңыз келе ме?',
      'review_deleted': 'Пікір жойылды',
      'view_all_reviews': 'Барлық пікірлерді көру',
      'send_review': 'Пікір жіберу',
      'review_hint': 'Шебердің жұмысы туралы пікіріңізді жазыңыз...',
      'review_required': 'Пікір жазуыңызды сұраймыз',
      'add_photo': 'Фото қосу',
      'max_photos_reached': 'Фото лимиті толды',
      'max_photos_warning': 'Максимум 5 фото жүктей аласыз',
      'photo_limit': 'Фотолар',

      // Profile
      'my_profile': 'Менің профилім',
      'edit_profile': 'Профильді өңдеу',
      'notifications': 'Хабарландырулар',
      'push_notifications': 'Push-хабарландырулар',
      'email_notifications': 'Email-хабарландырулар',
      'sms_notifications': 'SMS-хабарландырулар',
      'settings': 'Баптаулар',
      'profile_updated': 'Профиль жаңартылды',
      'logout': 'Шығу',
    },

    'en': {
      // Общие
      'app_name': 'Astana Beauty Salon',
      'ok': 'OK',
      'my_reviews': 'My Reviews',
      'no_reviews_yet': 'You don\'t have any reviews yet',
      'account_management': 'Account Management',
      'loyalty_program': 'Loyalty Program',
      'earned_points': 'Earned Points',
      'points_history': 'Points History',
      'points_usage': 'Points Usage',
      'available_promotions': 'Available Promotions',
      'no_points_history': 'You don\'t have any points history yet',
      'no_available_promotions': 'No promotions available at the moment',
      'redeem': 'Redeem',
      'points': 'points',
      'valid_until': 'Valid until',
      'not_enough_points': 'Not enough points',
      'redeem_promotion': 'Redeem Promotion',
      'confirm_redeem_promotion': 'Do you really want to use this promotion',
      'for': 'for',
      'confirm': 'Confirm',
      'promotion_redeemed': 'Promotion successfully redeemed',
      'loyalty_level_basic': 'Basic Level',
      'loyalty_level_silver': 'Silver Level (5% Discount)',
      'loyalty_level_gold': 'Gold Level (10% Discount)',
      'loyalty_level_platinum': 'Platinum Level (15% Discount)',
      'earn_points_hint': 'Earn points with each appointment and exchange them for discounts and special offers',
      'points_earning_rule': 'You earn 1 point for every 100 tenge in your order',

      // Auth
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'name': 'Name',
      'phone': 'Phone',
      'forgot_password': 'Forgot Password?',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account?',
      'signup_now': 'Sign Up Now',
      'login_now': 'Login Now',
      'password_reset': 'Password Reset',
      'password_reset_instructions': 'Enter your email to receive instructions',
      'send_instructions': 'Send Instructions',
      'password_reset_sent': 'Instructions sent',

      // Navigation
      'home': 'Home',
      'services': 'Services',
      'appointments': 'Appointments',
      'profile': 'Profile',

      // Services
      'all_services': 'All Services',
      'search_services': 'Search Services',
      'book_service': 'Book Service',
      'duration': 'Duration',
      'price': 'Price',
      'minutes': 'min',
      'no_services_found': 'No Services Found',
      'description': 'Description',
      'available_masters': 'Available Masters',

      // Masters
      'masters': 'Masters',
      'experience': 'Experience',
      'specializations': 'Specializations',
      'portfolio': 'Portfolio',
      'reviews': 'Reviews',
      'about_master': 'About Master',
      'book_with_master': 'Book with Master',
      'no_portfolio_items': 'No Portfolio Items',
      'schedule': 'Schedule',
      'day_off': 'Day Off',
      'breaks': 'Breaks',

      // Reviews
      'leave_review': 'Leave Review',
      'rate_service': 'Rate Service',
      'write_review': 'Write Review',
      'upload_photo': 'Upload Photo',
      'thank_for_review': 'Thank you for your review!',
      'no_reviews': 'No Reviews',
      'delete_review': 'Delete Review',
      'delete_review_confirmation': 'Are you sure you want to delete this review?',
      'review_deleted': 'Review deleted',
      'view_all_reviews': 'View All Reviews',
      'send_review': 'Send Review',
      'review_hint': 'Write your opinion about the master\'s work...',
      'review_required': 'Please write a review',
      'add_photo': 'Add Photo',
      'max_photos_reached': 'Photo limit reached',
      'max_photos_warning': 'You can upload maximum 5 photos',
      'photo_limit': 'Photos',

      // Profile
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
      'notifications': 'Notifications',
      'push_notifications': 'Push Notifications',
      'email_notifications': 'Email Notifications',
      'sms_notifications': 'SMS Notifications',
      'settings': 'Settings',
      'profile_updated': 'Profile Updated',
      'logout': 'Logout',
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
  
  // Отзывы
  String get myReviews => translate('my_reviews');
  String get noReviewsYet => translate('no_reviews_yet');
  String get accountManagement => translate('account_management');
  String get loyaltyProgram => translate('loyalty_program');
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