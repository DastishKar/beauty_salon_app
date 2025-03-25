// lib/screens/client/services_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Загрузка категорий и услуг
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Реализовать загрузку категорий и услуг из Firebase
    // Временно используем заглушки

    // Заглушки для категорий
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
      CategoryModel(
        id: '2',
        name: {
          'ru': 'Парикмахерские услуги',
          'kk': 'Шаштараз қызметтері',
          'en': 'Hair services',
        },
        description: {
          'ru': 'Стрижки, окрашивание и укладка',
          'kk': 'Шаш қию, бояу және сәндеу',
          'en': 'Haircuts, coloring and styling',
        },
        photoURL: null,
        order: 1,
      ),
      CategoryModel(
        id: '3',
        name: {
          'ru': 'Ногтевой сервис',
          'kk': 'Тырнақ қызметі',
          'en': 'Nail services',
        },
        description: {
          'ru': 'Маникюр, педикюр, наращивание',
          'kk': 'Маникюр, педикюр, ұзарту',
          'en': 'Manicure, pedicure, extensions',
        },
        photoURL: null,
        order: 2,
      ),
      CategoryModel(
        id: '4',
        name: {
          'ru': 'Макияж',
          'kk': 'Макияж',
          'en': 'Makeup',
        },
        description: {
          'ru': 'Профессиональный макияж',
          'kk': 'Кәсіби макияж',
          'en': 'Professional makeup',
        },
        photoURL: null,
        order: 3,
      ),
    ];

    // Заглушки для услуг
    _services = [
      ServiceModel(
        id: '1',
        name: {
          'ru': 'Женская стрижка',
          'kk': 'Әйелдер шаш қию',
          'en': 'Women\'s haircut',
        },
        description: {
          'ru': 'Профессиональная женская стрижка от наших стилистов',
          'kk': 'Біздің стилистерден кәсіби әйелдер шаш қию',
          'en': 'Professional women\'s haircut from our stylists',
        },
        category: '2',
        duration: 60,
        price: 5000,
        photoURL: null,
        availableMasters: {'1': true, '2': true},
      ),
      ServiceModel(
        id: '2',
        name: {
          'ru': 'Мужская стрижка',
          'kk': 'Ерлер шаш қию',
          'en': 'Men\'s haircut',
        },
        description: {
          'ru': 'Профессиональная мужская стрижка от наших барберов',
          'kk': 'Біздің барберлерден кәсіби ерлер шаш қию',
          'en': 'Professional men\'s haircut from our barbers',
        },
        category: '2',
        duration: 30,
        price: 3000,
        photoURL: null,
        availableMasters: {'1': true},
      ),
      ServiceModel(
        id: '3',
        name: {
          'ru': 'Маникюр классический',
          'kk': 'Классикалық маникюр',
          'en': 'Classic manicure',
        },
        description: {
          'ru': 'Классический маникюр с покрытием',
          'kk': 'Жабыны бар классикалық маникюр',
          'en': 'Classic manicure with coating',
        },
        category: '3',
        duration: 60,
        price: 4000,
        photoURL: null,
        availableMasters: {'3': true},
      ),
      ServiceModel(
        id: '4',
        name: {
          'ru': 'Дневной макияж',
          'kk': 'Күндізгі макияж',
          'en': 'Day makeup',
        },
        description: {
          'ru': 'Легкий макияж для повседневного образа',
          'kk': 'Күнделікті бейнеге арналған жеңіл макияж',
          'en': 'Light makeup for everyday look',
        },
        category: '4',
        duration: 45,
        price: 5000,
        photoURL: null,
        availableMasters: {'4': true},
      ),
    ];

    _tabController = TabController(length: _categories.length, vsync: this);
    _filterServices('');

    setState(() {
      _isLoading = false;
    });
  }

  // Фильтрация услуг по категории и поисковому запросу
  void _filterServices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      
      if (_tabController.index == 0) {
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
        final categoryId = _categories[_tabController.index].id;
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