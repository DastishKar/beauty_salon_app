// lib/services/language_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService with ChangeNotifier {
  final SharedPreferences _prefs;
  
  // Ключ для хранения кода языка в SharedPreferences
  static const String _languageCodeKey = 'language_code';
  
  // Доступные языки
  static const List<Locale> supportedLocales = [
    Locale('ru', ''), // Русский (по умолчанию)
    Locale('kk', ''), // Казахский
    Locale('en', ''), // Английский
  ];
  
  // Текущая локаль
  Locale _locale;
  
  LanguageService(this._prefs) : 
    _locale = Locale(_prefs.getString(_languageCodeKey) ?? 'ru', '');
  
  // Получение текущей локали
  Locale get locale => _locale;
  
  // Получение текущего кода языка
  String get languageCode => _locale.languageCode;
  
  // Получение названия языка по коду
  String getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'kk':
        return 'Қазақша';
      case 'en':
        return 'English';
      default:
        return 'Русский';
    }
  }
  
  // Название текущего языка
  String get currentLanguageName => getLanguageName(languageCode);
  
  // Установка языка по коду
  Future<void> setLanguage(String languageCode) async {
    // Проверка что код языка поддерживается
    if (!supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      return;
    }
    
    // Сохранение в настройках
    await _prefs.setString(_languageCodeKey, languageCode);
    
    // Обновление текущей локали
    _locale = Locale(languageCode, '');
    
    // Уведомление слушателей
    notifyListeners();
  }
}