// lib/screens/client/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  String _selectedLanguage = 'ru';

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  // Инициализация данных пользователя
  Future<void> _initUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    final user = authService.currentUserModel;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phoneNumber;
      _selectedLanguage = languageService.languageCode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Выбор изображения из галереи
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Сохранение изменений профиля
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final languageService = Provider.of<LanguageService>(context, listen: false);
      
      // Обновление языка
      if (languageService.languageCode != _selectedLanguage) {
        await languageService.setLanguage(_selectedLanguage);
      }
      
      // Обновление данных пользователя
      await authService.updateUserProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        language: _selectedLanguage,
      );
      
      // TODO: Обновление фото профиля, если выбрано
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('profile_updated')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
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
    final user = Provider.of<AuthService>(context).currentUserModel;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.translate('edit_profile'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('edit_profile')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Аватар пользователя
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (user.photoURL != null
                                ? NetworkImage(user.photoURL!) as ImageProvider
                                : null),
                        child: _selectedImage == null && user.photoURL == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Поле с именем
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('name'),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                // Поле с телефоном
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('phone'),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                
                // Выбор языка
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: InputDecoration(
                    labelText: localizations.translate('language'),
                    prefixIcon: const Icon(Icons.language),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'ru',
                      child: Text('Русский'),
                    ),
                    DropdownMenuItem(
                      value: 'kk',
                      child: Text('Қазақша'),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                
                // Кнопка сохранения
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text(localizations.translate('save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}