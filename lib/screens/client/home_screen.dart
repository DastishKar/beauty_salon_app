// lib/screens/client/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'services_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'masters_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Переключение вкладок
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Обработка свайпа страниц
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    Provider.of<AuthService>(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Отключаем свайп для избежания конфликтов
        children: const [
          DashboardScreen(),
          ServicesScreen(),
          MastersScreen(),
          AppointmentsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.spa),
            label: localizations.services,
          ),
          BottomNavigationBarItem(
          icon: const Icon(Icons.people), // Иконка для мастеров
          label: localizations.masters, // Используем геттер
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: localizations.appointments,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }
}