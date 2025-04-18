// lib/screens/admin/admin_masters_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../models/master_model.dart';
import '../../services/masters_service.dart';
import '../../widgets/loading_overlay.dart';
import 'edit_master_screen.dart';

class AdminMastersScreen extends StatefulWidget {
  const AdminMastersScreen({super.key});

  @override
  State<AdminMastersScreen> createState() => _AdminMastersScreenState();
}

class _AdminMastersScreenState extends State<AdminMastersScreen> {
  bool _isLoading = true;
  List<MasterModel> _masters = [];
  final MastersService _mastersService = MastersService();

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  // Загрузка мастеров
  Future<void> _loadMasters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final masters = await _mastersService.getAllMasters();
      
      setState(() {
        _masters = masters;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке мастеров: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке мастеров: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Добавление или редактирование мастера
  Future<void> _editMaster(MasterModel? master) async {
    // Переход на экран редактирования
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMasterScreen(master: master),
      ),
    );
    
    // Если вернулись с результатом true, обновляем список
    if (result == true) {
      _loadMasters();
    }
  }

  // Удаление мастера
  Future<void> _deleteMaster(MasterModel master) async {
    // Подтверждение удаления
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление мастера'),
        content: Text('Вы уверены, что хотите удалить мастера ${master.displayName}?'),
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
      // Добавить метод для удаления мастера в MastersService
      final success = await _mastersService.deleteMaster(master.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Мастер успешно удален'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadMasters();
      } else {
        throw Exception('Не удалось удалить мастера');
      }
    } catch (e) {
      debugPrint('Ошибка при удалении мастера: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении мастера: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Обновление портфолио мастера
  Future<void> _updatePortfolio(MasterModel master) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      // Выбор нескольких изображений
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isEmpty) return;
      
      setState(() {
        _isLoading = true;
      });
      
      // Преобразование XFile в File
      final List<File> files = images.map((xFile) => File(xFile.path)).toList();
      
      // Добавить метод для обновления портфолио мастера в MastersService
      final success = await _mastersService.updateMasterPortfolio(master.id, files);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Портфолио успешно обновлено'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadMasters();
      } else {
        throw Exception('Не удалось обновить портфолио');
      }
    } catch (e) {
      debugPrint('Ошибка при обновлении портфолио: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обновлении портфолио: $e'),
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
        body: _masters.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Мастера не найдены',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _editMaster(null),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить мастера'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadMasters,
                child: ListView.builder(
                  itemCount: _masters.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final master = _masters[index];
                    return _buildMasterCard(master);
                  },
                ),
              ),
        floatingActionButton: _masters.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _editMaster(null),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  // Карточка мастера
  Widget _buildMasterCard(MasterModel master) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото и имя мастера
            Row(
              children: [
                // Фото мастера с обработкой ошибок
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Builder(
                    builder: (context) {
                      if (master.photoBase64 == null || master.photoBase64!.isEmpty) {
                        return const Icon(Icons.person, size: 40, color: Colors.grey);
                      }

                      try {
                        return Image.memory(
                          base64Decode(master.photoBase64!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            if (kDebugMode) {
                              print('Error loading master photo: $error');
                              print('Stack trace: $stackTrace');
                            }
                            return const Icon(Icons.error_outline, size: 40, color: Colors.red);
                          },
                        );
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error decoding master photo: $e');
                        }
                        return const Icon(Icons.broken_image, size: 40, color: Colors.red);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Информация о мастере
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        master.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        master.specializations.join(', '),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${master.rating.toStringAsFixed(1)} (${master.reviewsCount} отзывов)',
                            style: TextStyle(
                              color: Colors.grey[700],
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
            
            // Информация о портфолио с обработкой ошибок
            Text(
              'Портфолио: ${master.portfolio.length} фото',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (master.portfolio.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: master.portfolio.length,
                  itemBuilder: (context, index) {
                    final imageBase64 = master.portfolio[index];
                    return Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Builder(
                        builder: (context) {
                          try {
                            return Image.memory(
                              base64Decode(imageBase64),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                if (kDebugMode) {
                                  print('Error loading portfolio image: $error');
                                }
                                return const Icon(Icons.error_outline, size: 30, color: Colors.red);
                              },
                            );
                          } catch (e) {
                            if (kDebugMode) {
                              print('Error decoding portfolio image: $e');
                            }
                            return const Icon(Icons.broken_image, size: 30, color: Colors.red);
                          }
                        },
                      ),
                    );
                  },
                ),
              )
            else
              const Text(
                'Нет фотографий в портфолио',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            
            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Кнопка обновления портфолио
                IconButton(
                  onPressed: () => _updatePortfolio(master),
                  icon: const Icon(Icons.photo_library),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Кнопка редактирования
                IconButton(
                  onPressed: () => _editMaster(master),
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Кнопка удаления
                IconButton(
                  onPressed: () => _deleteMaster(master),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.red),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}