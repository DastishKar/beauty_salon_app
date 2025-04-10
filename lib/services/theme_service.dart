// lib/services/theme_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  final SharedPreferences _prefs;
  
  // Ключ для хранения темы в SharedPreferences
  static const String _darkModeKey = 'dark_mode';
  
  // Текущая тема
  late ThemeMode _themeMode;
  
  ThemeService(this._prefs) {
    // Загружаем сохраненные настройки темы
    _themeMode = _loadThemeMode();
  }
  
  // Получение текущего режима темы
  ThemeMode get themeMode => _themeMode;
  
  // Проверка, включена ли темная тема
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Загрузка режима темы из SharedPreferences
  ThemeMode _loadThemeMode() {
    // Проверяем, есть ли сохраненное значение
    final isDark = _prefs.getBool(_darkModeKey);
    
    // Если значение есть, используем его, иначе используем системную тему
    if (isDark == null) {
      return ThemeMode.system;
    }
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
  
  // Установка светлой темы
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _prefs.setBool(_darkModeKey, false);
    notifyListeners();
  }
  
  // Установка темной темы
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _prefs.setBool(_darkModeKey, true);
    notifyListeners();
  }
  
  // Установка системной темы
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    await _prefs.remove(_darkModeKey);
    notifyListeners();
  }
  
  // Переключение между светлой и темной темой
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }
}