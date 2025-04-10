// lib/screens/client/create_review_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../../l10n/app_localizations.dart';
import '../../models/master_model.dart';
import '../../models/appointment_model.dart';
import '../../services/auth_service.dart';
import '../../services/reviews_service.dart';
import '../../services/appointments_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/loading_overlay.dart';

class CreateReviewScreen extends StatefulWidget {
  final MasterModel master;
  final AppointmentModel? appointment; // Необязательный параметр - запись, по которой создается отзыв
  
  const CreateReviewScreen({
    super.key,
    required this.master,
    this.appointment,
  });
  
  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ReviewsService _reviewsService = ReviewsService();
  final AppointmentsService _appointmentsService = AppointmentsService();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  bool _isLoading = false;
  double _rating = 5.0;
  final List<File> _selectedPhotos = [];
  List<AppointmentModel> _completedAppointments = [];
  AppointmentModel? _selectedAppointment;
  
  @override
  void initState() {
    super.initState();
    
    // Если передана запись на экран, устанавливаем её как выбранную
    if (widget.appointment != null) {
      _selectedAppointment = widget.appointment;
    }
    
    // Загружаем завершенные записи к мастеру
    _loadCompletedAppointments();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  // Загрузка завершенных записей к данному мастеру
  Future<void> _loadCompletedAppointments() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUserModel;
    
    if (currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Загружаем все прошлые записи пользователя
      final allPastAppointments = await _appointmentsService.getPastAppointments(currentUser.id);
      
      // Фильтруем только завершенные записи к данному мастеру
      final masterAppointments = allPastAppointments.where((appointment) => 
        appointment.masterId == widget.master.id && 
        appointment.status == 'completed').toList();
      
      // Для каждой записи проверяем, оставлен ли уже отзыв
      final List<AppointmentModel> appointmentsWithoutReview = [];
      
      for (var appointment in masterAppointments) {
        final hasReview = await _reviewsService.hasClientReviewedAppointment(
          currentUser.id, appointment.id);
        
        if (!hasReview) {
          appointmentsWithoutReview.add(appointment);
        }
      }
      
      if (!mounted) return;
      
      setState(() {
        _completedAppointments = appointmentsWithoutReview;
        
        // Если был передан appointment и его нет в списке, добавляем его
        if (widget.appointment != null && 
            !_completedAppointments.any((a) => a.id == widget.appointment!.id)) {
          _completedAppointments.add(widget.appointment!);
        }
        
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      debugPrint('Ошибка при загрузке записей: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке записей: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  
  
  // Показать диалог выбора источника для фотографии
  Future<void> _showImageSourceDialog() async {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('select_image_source')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(localizations.translate('gallery')),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(localizations.translate('camera')),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  
  
  // Выбор фотографий из галереи
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      // Если выбрано больше фотографий, чем осталось до лимита - предупреждаем
      if (pickedFiles.length > 5 - _selectedPhotos.length) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('max_photos_warning')),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      // Ограничиваем количество фотографий до лимита в 5
      final newPhotos = pickedFiles
          .take(5 - _selectedPhotos.length)
          .map((file) => File(file.path))
          .toList();
      
      setState(() {
        _selectedPhotos.addAll(newPhotos);
      });
    } catch (e) {
      debugPrint('Ошибка при выборе фотографий: $e');
    }
  }
  
  // Выбор фотографии с камеры
  Future<void> _pickImageFromCamera() async {
    try {
      // Проверка на лимит фотографий
      if (_selectedPhotos.length >= 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('max_photos_reached')),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        // Добавляем файл без обрезки
       setState(() {
         _selectedPhotos.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      debugPrint('Ошибка при съемке фотографии: $e');
    }
  }
  
  // Обрезка изображения
  Future<void> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Обрезка фото',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Обрезка фото',
          ),
        ],
      );
      
      if (croppedFile != null) {
        setState(() {
          _selectedPhotos.add(File(croppedFile.path));
        });
      }
    } catch (e) {
      debugPrint('Ошибка при обрезке изображения: $e');
    }
  }
  
  
  // Удаление фотографии
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }
  
  // Создание отзыва
  Future<void> _createReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUserModel;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('not_authenticated')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      
      // Создание отзыва с загруженными фотографиями
      final reviewId = await _reviewsService.createReview(
        clientId: currentUser.id,
        clientName: currentUser.displayName,
        clientPhotoURL: currentUser.photoURL,
        masterId: widget.master.id,
        appointmentId: _selectedAppointment?.id,
        rating: _rating,
        comment: _commentController.text.trim(),
        photoFiles: _selectedPhotos,
      );
      
      if (!mounted) return;
      
      if (reviewId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('thank_for_review')),
            backgroundColor: Colors.green,
          ),
        );
        
        // Возвращаемся с результатом true для обновления списка отзывов
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Не удалось создать отзыв');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при создании отзыва: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('leave_review')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация о мастере
                _buildMasterInfo(),
                const SizedBox(height: 24),
                
                // Выбор записи (если доступны завершенные записи)
                if (_completedAppointments.isNotEmpty) ...[
                  Text(
                    localizations.translate('select_appointment'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildAppointmentSelector(),
                  const SizedBox(height: 24),
                ],
                
                // Оценка рейтинга
                Text(
                  localizations.translate('rate_service'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildRatingSelector(),
                const SizedBox(height: 24),
                
                // Отзыв
                Text(
                  localizations.translate('write_review'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: localizations.translate('review_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizations.translate('review_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Загрузка фото
                Text(
                  localizations.translate('upload_photo'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildPhotoSelector(),
                const SizedBox(height: 32),
                
                // Кнопка отправки
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createReview,
                    child: Text(localizations.translate('send_review')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Виджет с информацией о мастере
  Widget _buildMasterInfo() {
    return Row(
      children: [
        // Фото мастера
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1*255).round()),
          backgroundImage: widget.master.photoURL != null
              ? NetworkImage(widget.master.photoURL!)
              : null,
          child: widget.master.photoURL == null
              ? const Icon(Icons.person, size: 30, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        
        // Информация о мастере
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.master.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                widget.master.specializations.join(', '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Селектор рейтинга
  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
        );
      }),
    );
  }
  
  // Селектор записи
  Widget _buildAppointmentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppointmentModel>(
          isExpanded: true,
          value: _selectedAppointment,
          hint: Text(AppLocalizations.of(context).translate('select_appointment')),
          items: _completedAppointments.map((appointment) {
            // Форматируем дату и время
            final date = '${appointment.date.day}.${appointment.date.month}.${appointment.date.year}';
            return DropdownMenuItem<AppointmentModel>(
              value: appointment,
              child: Text('$date, ${appointment.startTime} - ${appointment.serviceName}'),
            );
          }).toList(),
          onChanged: (AppointmentModel? value) {
            setState(() {
              _selectedAppointment = value;
            });
          },
        ),
      ),
    );
  }
  
  // Виджет для выбора и отображения фотографий
  Widget _buildPhotoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Выбранные фотографии
        if (_selectedPhotos.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // Фото
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedPhotos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Кнопка удаления
                    Positioned(
                      right: 8,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Кнопка добавления фото
        OutlinedButton.icon(
          onPressed: _selectedPhotos.length < 5 ? _showImageSourceDialog : null,
          icon: const Icon(Icons.photo_camera),
          label: Text(
            _selectedPhotos.length < 5
                ? AppLocalizations.of(context).translate('add_photo')
                : AppLocalizations.of(context).translate('max_photos_reached'),
          ),
        ),
        
        // Текст с информацией о лимите фотографий
        Text(
          '${AppLocalizations.of(context).translate('photo_limit')}: ${_selectedPhotos.length}/5',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}