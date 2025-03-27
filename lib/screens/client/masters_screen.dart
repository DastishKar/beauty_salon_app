// lib/screens/client/masters_screen.dart

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/master_model.dart';
import '../../services/masters_service.dart';
import '../../widgets/master_card.dart';
import '../../widgets/loading_overlay.dart';
import 'master_details_screen.dart';

class MastersScreen extends StatefulWidget {
  final String? selectedSpecialization;

  const MastersScreen({
    super.key,
    this.selectedSpecialization,
  });

  @override
  State<MastersScreen> createState() => _MastersScreenState();
}

class _MastersScreenState extends State<MastersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<MasterModel> _masters = [];
  List<MasterModel> _filteredMasters = [];
  String _searchQuery = '';
  String? _selectedSpecialization;
  List<String> _specializationsList = [];

  @override
  void initState() {
    super.initState();
    _selectedSpecialization = widget.selectedSpecialization;
    _loadMasters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Загрузка мастеров из Firebase
  Future<void> _loadMasters() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final mastersService = MastersService();
    
    // Use the debugPrint to see if the method is executing
    debugPrint('Attempting to load masters from Firebase...');
    
    final masters = await mastersService.getAllMasters();
    
    // Log the number of masters retrieved
    debugPrint('Loaded ${masters.length} masters from Firebase');
    
    // Extract unique specializations
    final Set<String> specializations = {};
    for (var master in masters) {
      specializations.addAll(master.specializations);
    }
    
    setState(() {
      _masters = masters;
      _specializationsList = specializations.toList()..sort();
      _filterMasters();
      _isLoading = false;
    });
    
    // If no masters were found, show a message
    if (masters.isEmpty) {
      debugPrint('No masters found in Firebase');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No masters found. Please add masters to your database.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    // Log the error
    debugPrint('Error loading masters: $e');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading masters: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  // Фильтрация мастеров по поисковому запросу и специализации
  void _filterMasters() {
    setState(() {
      _filteredMasters = _masters.where((master) {
        // Проверка на соответствие поисковому запросу
        final matchesQuery = _searchQuery.isEmpty ||
          master.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Проверка на соответствие выбранной специализации
        final matchesSpecialization = _selectedSpecialization == null ||
          master.specializations.contains(_selectedSpecialization);
        
        return matchesQuery && matchesSpecialization;
      }).toList();
    });
  }

  // Обработка изменения текста в поисковой строке
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    _filterMasters();
  }

  // Обработка выбора специализации
  void _onSpecializationSelected(String? specialization) {
    setState(() {
      _selectedSpecialization = specialization;
    });
    _filterMasters();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('masters')),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Поисковая строка
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: localizations.translate('search_masters'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            
            // Фильтры по специализации
            if (_specializationsList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Опция "Все"
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(localizations.translate('all')),
                          selected: _selectedSpecialization == null,
                          onSelected: (selected) {
                            if (selected) {
                              _onSpecializationSelected(null);
                            }
                          },
                        ),
                      ),
                      
                      // Опции специализаций
                      ..._specializationsList.map((specialization) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(specialization),
                            selected: _selectedSpecialization == specialization,
                            onSelected: (selected) {
                              if (selected) {
                                _onSpecializationSelected(specialization);
                              } else {
                                _onSpecializationSelected(null);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Список мастеров
            Expanded(
              child: _filteredMasters.isEmpty
                  ? Center(
                      child: Text(
                        localizations.translate('no_masters_found'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredMasters.length,
                      itemBuilder: (context, index) {
                        final master = _filteredMasters[index];
                        return MasterCard(
                          master: master,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MasterDetailsScreen(
                                  master: master,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}