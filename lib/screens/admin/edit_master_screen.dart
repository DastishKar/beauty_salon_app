// lib/screens/admin/edit_master_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../models/master_model.dart';
import '../../services/masters_service.dart';
import '../../widgets/loading_overlay.dart';

class EditMasterScreen extends StatefulWidget {
  final MasterModel? master; // Если null, то создание нового мастера

  const EditMasterScreen({super.key, this.master});

  @override
  State<EditMasterScreen> createState() => _EditMasterScreenState();
}

class _EditMasterScreenState extends State<EditMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Контроллеры для полей формы
  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionRuController = TextEditingController();
  final _descriptionKkController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  
  // Переменные для выбранных специализаций и фото
  List<String> _selectedSpecializations = [];
  File? _selectedPhoto;
  String? _currentPhotoBase64; // Changed from _currentPhotoURL
  
  // Список доступных специализаций
  final List<String> _availableSpecializations = [
    'Парикмахер',
    'Колорист',
    'Стилист',
    'Визажист',
    'Мастер маникюра',
    'Мастер педикюра',
    'Барбер',
    'Мастер по бровям',
    'Лешмейкер',
  ];
  
  bool _isLoading = false;
  final MastersService _mastersService = MastersService();
  
  @override
  void initState() {
    super.initState();
    _initFormData();
  }
  
  // Инициализация данных формы
  void _initFormData() {
    if (widget.master != null) {
      // Заполнение формы данными существующего мастера
      _nameController.text = widget.master!.displayName;
      _experienceController.text = widget.master!.experience;
      _descriptionRuController.text = widget.master!.description['ru'] ?? '';
      _descriptionKkController.text = widget.master!.description['kk'] ?? '';
      _descriptionEnController.text = widget.master!.description['en'] ?? '';
      _selectedSpecializations = List<String>.from(widget.master!.specializations);
      _currentPhotoBase64 = widget.master!.photoBase64; // Changed from photoURL
    }
  }
  
  @override
  void dispose() {
    // Освобождение ресурсов
    _nameController.dispose();
    _experienceController.dispose();
    _descriptionRuController.dispose();
    _descriptionKkController.dispose();
    _descriptionEnController.dispose();
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
  
  // Сохранение данных мастера
  Future<void> _saveMaster() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Создание Map с описанием на разных языках
      final Map<String, String> description = {
        'ru': _descriptionRuController.text.trim(),
        'kk': _descriptionKkController.text.trim(),
        'en': _descriptionEnController.text.trim(),
      };
      
      if (widget.master == null) {
        // Создание нового мастера
        await _mastersService.createMaster(
          displayName: _nameController.text.trim(),
          experience: _experienceController.text.trim(),
          description: description,
          specializations: _selectedSpecializations,
          photoFile: _selectedPhoto,
        );
      } else {
        // Обновление существующего мастера
        await _mastersService.updateMaster(
          masterId: widget.master!.id,
          displayName: _nameController.text.trim(),
          experience: _experienceController.text.trim(),
          description: description,
          specializations: _selectedSpecializations,
          photoFile: _selectedPhoto,
          currentPhotoBase64: _currentPhotoBase64,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Мастер успешно сохранен'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(true); // Возвращаемся с результатом true
      }
    } catch (e) {
      debugPrint('Ошибка при сохранении мастера: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении мастера: $e'),
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
          title: Text(widget.master == null ? 'Добавление мастера' : 'Редактирование мастера'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Фото мастера
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            image: _selectedPhoto != null
                                ? DecorationImage(
                                    image: FileImage(_selectedPhoto!),
                                    fit: BoxFit.cover,
                                  )
                                : (_currentPhotoBase64 != null
                                    ? DecorationImage(
                                        image: MemoryImage(base64Decode((_currentPhotoBase64!))),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: (_selectedPhoto == null && _currentPhotoBase64 == null)
                              ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('Выбрать фото'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Имя мастера
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя мастера',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите имя мастера';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Опыт работы
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Опыт работы',
                    border: OutlineInputBorder(),
                    hintText: 'Например: 5 лет',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите опыт работы';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Специализации
                const Text(
                  'Специализации:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _availableSpecializations.map((specialization) {
                    final isSelected = _selectedSpecializations.contains(specialization);
                    return FilterChip(
                      label: Text(specialization),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSpecializations.add(specialization);
                          } else {
                            _selectedSpecializations.remove(specialization);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_selectedSpecializations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Выберите хотя бы одну специализацию',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Описание на русском
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
                      return 'Пожалуйста, введите описание на русском языке';
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
                const SizedBox(height: 24),
                
                // Кнопка сохранения
                Center(
                  child: ElevatedButton(
                    onPressed: _selectedSpecializations.isNotEmpty ? _saveMaster : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
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
}