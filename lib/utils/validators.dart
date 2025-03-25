// lib/utils/validators.dart

class Validators {
  // Валидация имени
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите имя';
    }
    if (value.length < 2) {
      return 'Имя должно содержать не менее 2 символов';
    }
    return null;
  }

  // Валидация email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите email';
    }
    
    // Регулярное выражение для проверки формата email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegex.hasMatch(value)) {
      return 'Пожалуйста, введите корректный email';
    }
    
    return null;
  }

  // Валидация телефона
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите номер телефона';
    }
    
    // Удаление всех нецифровых символов для проверки
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Проверка длины номера (для Казахстана обычно 11 цифр с кодом 7)
    if (digitsOnly.length < 10 || digitsOnly.length > 12) {
      return 'Пожалуйста, введите корректный номер телефона';
    }
    
    return null;
  }

  // Валидация пароля
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите пароль';
    }
    
    if (value.length < 6) {
      return 'Пароль должен содержать не менее 6 символов';
    }
    
    return null;
  }

  // Валидация даты
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, выберите дату';
    }
    
    try {
      // Попытка разобрать дату
      final date = DateTime.parse(value);
      
      // Проверка, не выбрана ли прошедшая дата
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return 'Нельзя выбрать прошедшую дату';
      }
    } catch (e) {
      return 'Пожалуйста, введите дату в формате ГГГГ-ММ-ДД';
    }
    
    return null;
  }

  // Валидация времени
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, выберите время';
    }
    
    // Регулярное выражение для проверки формата времени (ЧЧ:ММ)
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    
    if (!timeRegex.hasMatch(value)) {
      return 'Пожалуйста, введите время в формате ЧЧ:ММ';
    }
    
    return null;
  }

  // Валидация числового поля
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите число';
    }
    
    // Проверка, является ли строка числом
    final number = int.tryParse(value);
    if (number == null) {
      return 'Пожалуйста, введите корректное число';
    }
    
    // Проверка минимального значения
    if (min != null && number < min) {
      return 'Значение должно быть не менее $min';
    }
    
    // Проверка максимального значения
    if (max != null && number > max) {
      return 'Значение должно быть не более $max';
    }
    
    return null;
  }

  // Валидация суммы
  static String? validateAmount(String? value, {double? min}) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите сумму';
    }
    
    // Проверка, является ли строка числом
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) {
      return 'Пожалуйста, введите корректную сумму';
    }
    
    // Проверка на отрицательное значение
    if (amount < 0) {
      return 'Сумма не может быть отрицательной';
    }
    
    // Проверка минимального значения
    if (min != null && amount < min) {
      return 'Сумма должна быть не менее $min';
    }
    
    return null;
  }
}