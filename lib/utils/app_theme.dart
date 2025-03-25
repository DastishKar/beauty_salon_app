// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Основные цвета
  static const Color primaryColor = Color(0xFF9C27B0); // Фиолетовый (основной цвет)
  static const Color secondaryColor = Color(0xFFE91E63); // Розовый (акцентный цвет)
  static const Color backgroundColor = Color(0xFFF5F5F5); // Светло-серый фон
  static const Color darkBackgroundColor = Color(0xFF212121); // Темно-серый фон для темной темы
  
  // Цвета для текста
  static const Color textColor = Color(0xFF333333); // Основной цвет текста
  static const Color textLightColor = Color(0xFF666666); // Светлый текст
  static const Color textDarkColor = Color(0xFFEEEEEE); // Текст для темной темы
  
  // Цвета для статусов
  static const Color successColor = Color(0xFF4CAF50); // Зеленый
  static const Color errorColor = Color(0xFFF44336); // Красный
  static const Color warningColor = Color(0xFFFF9800); // Оранжевый
  static const Color infoColor = Color(0xFF2196F3); // Синий
  
  // Светлая тема
  static late final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    primarySwatch: Colors.purple,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      labelLarge: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      type: BottomNavigationBarType.fixed,
    ),
  ),

  // Темная тема
  static; final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    primarySwatch: Colors.purple,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF303030),
      background: darkBackgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF303030),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textDarkColor, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textDarkColor, fontSize: 22, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textDarkColor, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textDarkColor, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textDarkColor, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textDarkColor, fontSize: 16),
      bodyMedium: TextStyle(color: textDarkColor, fontSize: 14),
      labelLarge: TextStyle(color: textDarkColor, fontSize: 14, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF424242),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF555555)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF303030),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF303030),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      type: BottomNavigationBarType.fixed,
    ),
  );
}