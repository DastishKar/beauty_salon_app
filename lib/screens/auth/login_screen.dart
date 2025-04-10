// lib/screens/auth/login_screen.dart

import 'package:beauty_salon_app/screens/admin/admin_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../client/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Метод для выполнения входа
  Future<void> _login() async {
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
      
      // Выполнение входа
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        if (authService.isAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Логотип
                    Icon(
                      Icons.spa,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    
                    // Заголовок
                    Text(
                      localizations.login,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Поле email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: localizations.email,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    
                    // Поле пароль
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: localizations.password,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: Validators.validatePassword,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 8),
                    
                    // Ссылка "Забыли пароль?"
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(localizations.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Кнопка входа
                    ElevatedButton(
                      onPressed: _login,
                      child: Text(localizations.login),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ссылка на регистрацию
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(localizations.noAccount),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(localizations.signupNow),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}