// lib/screens/client/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'services_screen.dart';
import 'masters_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static final GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}


class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _needRefreshAppointments = false; // Флаг для обновления списка записей
  final int _unreadNotificationsCount = 0;

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
    // Если переходим на вкладку записей и есть флаг обновления
    if (index == 3 && _needRefreshAppointments) {
      _needRefreshAppointments = false;
      // Здесь можно добавить логику для обновления списка записей
      // Например, вызвать метод обновления в AppointmentsScreen
    }
    
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

  // Метод для установки флага обновления записей
  void setNeedRefreshAppointments() {
    _needRefreshAppointments = true;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    Provider.of<AuthService>(context);
  
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const DashboardScreen(),
          const ServicesScreen(),
          const MastersScreen(),
          AppointmentsScreen(key: appointmentsScreenKey),
          const ProfileScreen(),
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
            icon: const Icon(Icons.people),
            label: localizations.masters,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: localizations.appointments,
         ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.person),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _unreadNotificationsCount > 9 ? '9+' : '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }
}