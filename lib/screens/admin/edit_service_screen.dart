// lib/screens/admin/edit_service_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../models/service_model.dart';
import '../../models/category_model.dart';
import '../../services/services_service.dart';
import '../../widgets/loading_overlay.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel? service; // Если null, то создание новой услуги
  final List<CategoryModel> categories;

  const EditServiceScreen({
    super.key,
    this.service,
    required this.categories,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей формы
  final _nameRuController = TextEditingController();
  final _nameKkController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descriptionRuController = TextEditingController();
  final _descriptionKkController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  // Выбранная категория
  String? _selectedCategoryId;
  File? _selectedPhoto;
  String? _currentPhotoBase64; // Changed from _currentPhotoURL
  bool _isActive = true;

  bool _isLoading = false;
  final ServicesService _servicesService = ServicesService();

  @override
  void initState() {
    super.initState();
    _initFormData();
  }

  // Инициализация данных формы
  void _initFormData() {
    if (widget.service != null) {
      // Заполнение формы данными существующей услуги
      _nameRuController.text = widget.service!.name['ru'] ?? '';
      _nameKkController.text = widget.service!.name['kk'] ?? '';
      _nameEnController.text = widget.service!.name['en'] ?? '';
      _descriptionRuController.text = widget.service!.description['ru'] ?? '';
      _descriptionKkController.text = widget.service!.description['kk'] ?? '';
      _descriptionEnController.text = widget.service!.description['en'] ?? '';
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.duration.toString();
      _selectedCategoryId = widget.service!.category;
      _currentPhotoBase64 = widget.service!.photoBase64;
      _isActive = widget.service!.isActive;
    } else if (widget.categories.isNotEmpty) {
      // Установка категории по умолчанию для новой услуги
      _selectedCategoryId = widget.categories[0].id;
    }
  }

  @override
  void dispose() {
    // Освобождение ресурсов
    _nameRuController.dispose();
    _nameKkController.dispose();
    _nameEnController.dispose();
    _descriptionRuController.dispose();
    _descriptionKkController.dispose();
    _descriptionEnController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // Выбор фото из галереи
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выборе изображения: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Сохранение данных услуги
  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите категорию'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Создание Map с именем на разных языках
      final Map<String, String> name = {
        'ru': _nameRuController.text.trim(),
        'kk': _nameKkController.text.trim(),
        'en': _nameEnController.text.trim(),
      };

      // Создание Map с описанием на разных языках
      final Map<String, String> description = {
        'ru': _descriptionRuController.text.trim(),
        'kk': _descriptionKkController.text.trim(),
        'en': _descriptionEnController.text.trim(),
      };

      // Чтение цены и продолжительности
      final int price = int.tryParse(_priceController.text.trim()) ?? 0;
      final int duration = int.tryParse(_durationController.text.trim()) ?? 60;

      if (widget.service == null) {
        // Создание новой услуги
        await _servicesService.createService(
          name: name,
          description: description,
          category: _selectedCategoryId!,
          price: price,
          duration: duration,
          photoFile: _selectedPhoto,
          isActive: _isActive,
        );
      } else {
        // Обновление существующей услуги
        await _servicesService.updateService(
          serviceId: widget.service!.id,
          name: name,
          description: description,
          category: _selectedCategoryId!,
          price: price,
          duration: duration,
          photoFile: _selectedPhoto,
          currentPhotoBase64: _currentPhotoBase64,
          isActive: _isActive,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Услуга успешно сохранена'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true); // Возвращаемся с результатом true
      }
    } catch (e) {
      debugPrint('Ошибка при сохранении услуги: $e');

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении услуги: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.service == null ? 'Добавление услуги' : 'Редактирование услуги'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Фото услуги
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Builder(
                            builder: (context) {
                              if (_selectedPhoto != null) {
                                return Image.file(
                                  _selectedPhoto!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    if (kDebugMode) {
                                      print('Error loading selected photo: $error');
                                    }
                                    return _buildErrorPlaceholder();
                                  },
                                );
                              }

                              if (_currentPhotoBase64 != null) {
                                try {
                                  return Image.memory(
                                    base64Decode(_currentPhotoBase64!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      if (kDebugMode) {
                                        print('Error loading current photo: $error');
                                      }
                                      return _buildErrorPlaceholder();
                                    },
                                  );
                                } catch (e) {
                                  if (kDebugMode) {
                                    print('Error decoding base64 image: $e');
                                  }
                                  return _buildErrorPlaceholder();
                                }
                              }

                              return const Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Выбрать фото'),
                          ),
                          if (_selectedPhoto != null || _currentPhotoBase64 != null) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedPhoto = null;
                                  _currentPhotoBase64 = null;
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Удалить', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Выбор категории
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name['ru'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Название на русском (обязательное)
                TextFormField(
                  controller: _nameRuController,
                  decoration: const InputDecoration(
                    labelText: 'Название (Русский)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите название услуги';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Название на казахском
                TextFormField(
                  controller: _nameKkController,
                  decoration: const InputDecoration(
                    labelText: 'Название (Қазақша)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Название на английском
                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'Название (English)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Цена и продолжительность в одном ряду
                Row(
                  children: [
                    // Цена
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Цена (₸)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите цену';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Цена должна быть числом';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Продолжительность
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Длительность (мин)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите время';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Должно быть числом';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Описание на русском (обязательное)
                TextFormField(
                  controller: _descriptionRuController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (Русский)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите описание услуги';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Описание на казахском
                TextFormField(
                  controller: _descriptionKkController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (Қазақша)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Описание на английском
                TextFormField(
                  controller: _descriptionEnController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (English)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Чекбокс активности услуги
                CheckboxListTile(
                  title: const Text('Активна'),
                  subtitle: const Text('Отображать услугу в приложении'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Кнопка сохранения
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveService,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.red,
        ),
        SizedBox(height: 4),
        Text(
          'Ошибка загрузки',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}