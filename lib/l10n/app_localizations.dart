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
      'no_points_history': 'У вас пока нет истории баллов',
      'no_available_promotions': 'Доступных акций пока нет',
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
      'loyalty_level_silver': 'Серебряный уровень (Скидка 5%)',
      'loyalty_level_gold': 'Золотой уровень (Скидка 10%)',
      'loyalty_level_platinum': 'Платиновый уровень (Скидка 15%)',
      'earn_points_hint': 'Накапливайте баллы с каждой записью и обменивайте их на скидки и специальные предложения',
      'points_earning_rule': 'Вы получаете 1 балл за каждые 100 тенге в вашем заказе',
      
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
    },
    
    // Для казахского языка
    'kk': {
      // Общие
      'app_name': 'Астана сұлулық салоны',
      'ok': 'OK',
      // ... добавьте здесь все необходимые переводы на казахский
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
    },
    
    // Для английского языка
    'en': {
      // Общие
      'app_name': 'Astana Beauty Salon',
      'ok': 'OK',
      // ... добавьте здесь все необходимые переводы на английский
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
      'points_earning_rule': 'You earn 1 point for every 100 tenge in your order'
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