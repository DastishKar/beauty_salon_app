import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../services/image_upload_service.dart';
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
  final ImageUploadService _imageUploadService = ImageUploadService();

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
      setState(() {
        _nameController.text = user.displayName;
        _phoneController.text = user.phoneNumber;
        _selectedLanguage = languageService.languageCode;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Выбор изображения из галереи
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        if (kDebugMode) {
          print('Изображение выбрано из галереи: ${image.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при выборе изображения из галереи: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  // Выбор изображения с камеры
  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        if (kDebugMode) {
          print('Изображение сделано камерой: ${image.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при съемке фото: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при съемке фото: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  // Обрезка изображения
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Обрезка фото',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Обрезка фото',
          ),
        ],
      );
      
      if (croppedFile != null) {
        if (kDebugMode) {
          print('Изображение обрезано: ${croppedFile.path}');
        }
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обрезке изображения: $e');
      }
      return null;
    }
  }
  
  // Показать диалог выбора источника изображения
  Future<void> _showImageSourceDialog() async {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('select_image_source')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text(localizations.translate('gallery')),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromGallery();
                  },
                ),
                const Divider(),
                GestureDetector(
                  child: ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(localizations.translate('camera')),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
      
      // Получаем текущего пользователя
      final currentUser = authService.currentUserModel;
      if (currentUser == null) {
        throw Exception('Пользователь не найден');
      }
      
      // Base64 фото профиля
      String? photoBase64 = currentUser.photoBase64;
      
      // Загружаем новое фото, если оно выбрано
      if (_selectedImage != null) {
        try {
          if (kDebugMode) {
            print('Начинаем загрузку нового фото профиля');
          }
          
          // Загружаем новое фото
          photoBase64 = await _imageUploadService.uploadImage(
            _selectedImage!, 
            'users/${currentUser.id}/profile',
          );
          
          if (kDebugMode) {
            print('Новое фото профиля успешно загружено');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Ошибка при обработке изображения: $e');
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка при загрузке фото: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            
            setState(() {
              _isLoading = false;
            });
          }
          return; // Прерываем выполнение при ошибке загрузки фото
        }
      }
      
      // Обновление языка
      if (languageService.languageCode != _selectedLanguage) {
        await languageService.setLanguage(_selectedLanguage);
      }
      
      // Обновление данных пользователя
      await authService.updateUserProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        language: _selectedLanguage,
        photoBase64: photoBase64,
      );
      
      if (kDebugMode) {
        print('Профиль успешно обновлен');
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('profile_updated')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при сохранении изменений: $e');
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обновлении профиля: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (user.photoBase64 != null
                                ? MemoryImage(base64Decode(user.photoBase64!)) as ImageProvider
                                : null),
                        child: _selectedImage == null && user.photoBase64 == null
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
                            Icons.camera_alt,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text(localizations.translate('save')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}