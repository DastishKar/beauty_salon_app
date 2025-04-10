// lib/screens/admin/admin_services_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/service_model.dart';
import '../../models/category_model.dart';
import '../../services/services_service.dart';
import '../../widgets/loading_overlay.dart';
import 'edit_service_screen.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<ServiceModel> _services = [];
  List<CategoryModel> _categories = [];
  late TabController _tabController;
  
  final ServicesService _servicesService = ServicesService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Загрузка категорий и услуг
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Загружаем категории
      final categories = await _servicesService.getCategories();
      
      // Загружаем все услуги
      final services = await _servicesService.getAllServices();
      
      setState(() {
        _categories = categories;
        _services = services;
        
        // Инициализируем TabController после загрузки категорий
        _tabController = TabController(length: categories.length, vsync: this);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке данных: $e');
      
      setState(() {
        // Создаем хотя бы одну категорию "Все услуги", если загрузка не удалась
        _categories = [
          CategoryModel(
            id: '1',
            name: {'ru': 'Все услуги', 'kk': 'Барлық қызметтер', 'en': 'All services'},
            description: {'ru': '', 'kk': '', 'en': ''},
            order: 0,
          ),
        ];
        
        _services = [];
        _tabController = TabController(length: _categories.length, vsync: this);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке данных: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Добавление или редактирование услуги
  Future<void> _editService(ServiceModel? service) async {
    // Переход на экран редактирования
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          service: service,
          categories: _categories,
        ),
      ),
    );
    
    // Если вернулись с результатом true, обновляем список
    if (result == true) {
      _loadData();
    }
  }

  // Удаление услуги
  Future<void> _deleteService(ServiceModel service) async {
    // Подтверждение удаления
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление услуги'),
        content: Text('Вы уверены, что хотите удалить услугу "${service.name['ru']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await _servicesService.deleteService(service.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Услуга успешно удалена'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadData();
      } else {
        throw Exception('Не удалось удалить услугу');
      }
    } catch (e) {
      debugPrint('Ошибка при удалении услуги: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении услуги: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Обновление фото услуги
  Future<void> _updateServicePhoto(ServiceModel service) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image == null) return;
      
      setState(() {
        _isLoading = true;
      });
      
      final File file = File(image.path);
      
      final success = await _servicesService.updateServicePhoto(service.id, file);
      
      if (success != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Фото услуги успешно обновлено'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadData();
      } else {
        throw Exception('Не удалось обновить фото услуги');
      }
    } catch (e) {
      debugPrint('Ошибка при обновлении фото услуги: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обновлении фото: $e'),
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
        body: _categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.spa_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Нет доступных категорий',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Обновить'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Табы с категориями
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: _categories.map((category) {
                      return Tab(text: category.name['ru'] ?? '');
                    }).toList(),
                  ),
                  
                  // Список услуг в зависимости от выбранной категории
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _categories.map((category) {
                        // Фильтруем услуги по категории или показываем все для первой категории
                        final categoryServices = category.id == '1'
                            ? _services
                            : _services.where((service) => service.category == category.id).toList();
                            
                        if (categoryServices.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.spa_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Услуги не найдены',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: categoryServices.length,
                          itemBuilder: (context, index) {
                            final service = categoryServices[index];
                            return _buildServiceCard(service);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _editService(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Карточка услуги
  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть с фото и информацией
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Фото услуги
                GestureDetector(
                  onTap: () => _updateServicePhoto(service),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: service.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(service.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: service.photoURL == null
                        ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Информация об услуге
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name['ru'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Категория
                      Text(
                        'Категория: ${_getCategoryName(service.category)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Цена и продолжительность
                      Row(
                        children: [
                          Text(
                            '${service.price} ₸',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${service.duration} мин',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Короткое описание
            Text(
              service.description['ru'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            
            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Кнопка обновления фото
                OutlinedButton.icon(
                  onPressed: () => _updateServicePhoto(service),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Фото'),
                ),
                const SizedBox(width: 8),
                
                // Кнопка редактирования
                OutlinedButton.icon(
                  onPressed: () => _editService(service),
                  icon: const Icon(Icons.edit),
                  label: const Text('Изменить'),
                ),
                const SizedBox(width: 8),
                
                // Кнопка удаления
                OutlinedButton.icon(
                  onPressed: () => _deleteService(service),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Удалить',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Получение названия категории по ID
  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => CategoryModel(
        id: '0',
        name: {'ru': 'Неизвестно', 'kk': 'Белгісіз', 'en': 'Unknown'},
        description: {'ru': '', 'kk': '', 'en': ''},
        order: 0,
      ),
    );
    
    return category.name['ru'] ?? '';
  }
}