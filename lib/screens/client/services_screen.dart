// lib/screens/client/services_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/services_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/language_service.dart';
import '../../models/service_model.dart';
import '../../models/category_model.dart';
import '../../widgets/service_card.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  String _searchQuery = '';


 @override
  void initState() {
    super.initState();
    _tabController = null;  // Initialize with null first
    _loadCategories();
  }

 @override
 void dispose() {
   // Safely dispose tabController only if it was initialized
   _tabController?.dispose();
   super.dispose();
 }

  // Then update the initCategories method to initialize _tabController
  Future<void> _loadCategories() async {
    setState(() {
    _isLoading = true;
  });

   try {
     // Create an instance of ServicesService
     final servicesService = ServicesService();
    
     // Load categories from Firestore
     final categories = await servicesService.getCategories();
    
     // Load all services from Firestore
     final services = await servicesService.getAllServices();
    
     if (mounted) {
       setState(() {
         // Set the loaded data
         _categories = categories;
        
         // If no categories were found, create a default "All Services" category
         if (_categories.isEmpty) {
           _categories = [
             CategoryModel(
               id: '1',
               name: {
                 'ru': 'Все услуги',
                 'kk': 'Барлық қызметтер',
                 'en': 'All services',
               },
               description: {
                 'ru': 'Все услуги нашего салона',
                 'kk': 'Біздің салонның барлық қызметтері',
                 'en': 'All services of our salon',
                },
               photoURL: null,
               order: 0,
              ),
            ];
          }
        
          _services = services;
        
         // Initialize the TabController after loading data
         _tabController = TabController(length: _categories.length, vsync: this);
        
         // Filter services based on initial state
         _filterServices('');
        
         _isLoading = false;
        });
      }
   } catch (e) {
     // Display error message only if widget is still mounted
     if (mounted) {
       debugPrint('Error loading services data: $e');
         setState(() {
         _isLoading = false;
        
         // Set fallback categories and initialize controller
         _categories = [
           CategoryModel(
             id: '1',
             name: {
               'ru': 'Все услуги',
               'kk': 'Барлық қызметтер',
               'en': 'All services',
              },
             description: {
               'ru': 'Все услуги нашего салона',
               'kk': 'Біздің салонның барлық қызметтері',
               'en': 'All services of our salon',
              },
             photoURL: null,
             order: 0,
            ),
          ];
         _tabController = TabController(length: _categories.length, vsync: this);
        });
      }
    }
 } 

  // Фильтрация услуг по категории и поисковому запросу
  void _filterServices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      
      if (_tabController?.index == 0) {
        // Все услуги
        _filteredServices = _services.where((service) {
          final nameRu = service.name['ru']?.toLowerCase() ?? '';
          final nameKk = service.name['kk']?.toLowerCase() ?? '';
          final nameEn = service.name['en']?.toLowerCase() ?? '';
          
          return _searchQuery.isEmpty ||
             nameRu.contains(_searchQuery) ||
             nameKk.contains(_searchQuery) ||
             nameEn.contains(_searchQuery);
        }).toList();
      } else {
        // Фильтрация по выбранной категории
        final categoryId = _categories[_tabController!.index].id;
        _filteredServices = _services.where((service) {
          final nameRu = service.name['ru']?.toLowerCase() ?? '';
          final nameKk = service.name['kk']?.toLowerCase() ?? '';
          final nameEn = service.name['en']?.toLowerCase() ?? '';
          
          final matchesCategory = service.category == categoryId;
          final matchesQuery = _searchQuery.isEmpty ||
             nameRu.contains(_searchQuery) ||
             nameKk.contains(_searchQuery) ||
             nameEn.contains(_searchQuery);
             
          return matchesCategory && matchesQuery;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Provider.of<LanguageService>(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('services')),
        automaticallyImplyLeading: false,
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _categories
                    .map((category) => Tab(
                          text: category.getLocalizedName(languageCode),
                        ))
                    .toList(),
                onTap: (index) {
                  _filterServices(_searchQuery);
                },
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Поисковая строка
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localizations.translate('search_services'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterServices('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _filterServices,
                  ),
                ),
                
                // Список услуг
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(
                      _categories.length,
                      (index) => _buildServicesList(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Построение списка услуг
  Widget _buildServicesList(BuildContext context) {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_services_found'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return ServiceCard(
          service: service,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ServiceDetailsScreen(service: service),
              ),
            );
          },
        );
      },
    );
  }
}