// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Метод для отправки запроса на восстановление пароля
  Future<void> _resetPassword() async {
    // Скрыть клавиатуру
    FocusScope.of(context).unfocus();
    
    // Проверка валидации формы
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Отправка инструкций по восстановлению пароля
      await authService.resetPassword(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _resetSent = true;
        });
      }
    } catch (e) {
      // Показать сообщение об ошибке
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

  @override
  @override
Widget build(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  
  return LoadingOverlay(
    isLoading: _isLoading,
    child: Scaffold(
      appBar: AppBar(
        title: Text(localizations.passwordReset), // Исправлено с password_reset
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _resetSent
              ? _buildSuccessView(localizations)
              : _buildResetForm(localizations),
        ),
      ),
    ),
  );
}

// Форма для ввода email
Widget _buildResetForm(AppLocalizations localizations) {
  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Заголовок и инструкция
        Text(
          localizations.passwordReset, // Исправлено
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          localizations.passwordResetInstructions, // Исправлено
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        
        // Поле для ввода email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: localizations.email,
            prefixIcon: const Icon(Icons.email),
          ),
          validator: Validators.validateEmail,
          onFieldSubmitted: (_) => _resetPassword(),
        ),
        const SizedBox(height: 32),
        
        // Кнопка отправки
        ElevatedButton(
          onPressed: _resetPassword,
          child: Text(localizations.sendInstructions), // Исправлено
        ),
      ],
    ),
  );
}

// Экран успешной отправки инструкций
Widget _buildSuccessView(AppLocalizations localizations) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 72,
        ),
        const SizedBox(height: 24),
        Text(
          localizations.passwordResetSent, // Исправлено
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.ok), // Исправлено
        ),
      ],
    ),
  );
}
}