// lib/screens/admin/admin_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

import '../../l10n/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../models/service_model.dart';
import '../../models/master_model.dart';
import '../../services/auth_service.dart';
import '../../services/appointments_service.dart';
import '../../services/services_service.dart';
import '../../services/masters_service.dart';
import '../../widgets/loading_overlay.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Services for data fetching
  final AppointmentsService _appointmentsService = AppointmentsService();
  final ServicesService _servicesService = ServicesService();
  final MastersService _mastersService = MastersService();
  
  // Data containers
  List<AppointmentModel> _appointments = [];
  List<ServiceModel> _services = [];
  List<MasterModel> _masters = [];
  
  // Analytics data
  int _totalAppointments = 0;
  double _totalRevenue = 0;
  int _completedAppointments = 0;
  int _cancelledAppointments = 0;
  double _completionRate = 0;
  
  // Filtered data for current period
  List<AppointmentModel> _currentPeriodAppointments = [];
  
  // Time period filters
  String _selectedPeriod = 'month'; // 'week', 'month', 'year'
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Load all necessary data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load appointments, services, and masters
      final appointments = await _appointmentsService.getAllAppointments();
      final services = await _servicesService.getAllServices();
      final masters = await _mastersService.getAllMasters();
      
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _services = services;
          _masters = masters;
          
          // Set date range based on selected period
          _updateDateRange();
          
          // Calculate analytics metrics
          _calculateAnalytics();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Update date range based on selected period
  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        _startDate = DateTime(now.year, now.month, now.day - 7);
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
        break;
      case 'year':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        _endDate = now;
        break;
      case 'custom':
        // Keep existing custom date range
        break;
    }
    
    // Filter appointments for current period
    _filterAppointmentsForPeriod();
  }
  
  // Filter appointments for the selected date range
  void _filterAppointmentsForPeriod() {
    _currentPeriodAppointments = _appointments.where((appointment) {
      return appointment.date.isAfter(_startDate) && 
             appointment.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Calculate analytics metrics based on filtered data
  void _calculateAnalytics() {
    // Filter appointments for current period
    _filterAppointmentsForPeriod();
    
    // Total appointments in period
    _totalAppointments = _currentPeriodAppointments.length;
    
    // Completed and cancelled appointments
    _completedAppointments = _currentPeriodAppointments
        .where((a) => a.status == 'completed')
        .length;
    
    _cancelledAppointments = _currentPeriodAppointments
        .where((a) => a.status == 'cancelled')
        .length;
    
    // Completion rate
    _completionRate = _totalAppointments > 0
        ? (_completedAppointments / _totalAppointments) * 100
        : 0;
    
    // Total revenue (from completed appointments)
    _totalRevenue = _currentPeriodAppointments
        .where((a) => a.status == 'completed')
        .fold(0, (sum, appointment) => sum + appointment.price);
  }
  
  // Change the selected time period
  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _updateDateRange();
      _calculateAnalytics();
    });
  }
  
  // Open date picker for custom date range
  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: _startDate,
      end: _endDate,
    );
    
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (newDateRange != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
        _calculateAnalytics();
      });
    }
  }
  
  // Get service name by ID
  String _getServiceName(String serviceId) {
    final service = _services.firstWhereOrNull((s) => s.id == serviceId);
    return service?.name['ru'] ?? 'Unknown Service';
  }
  
  // Get master name by ID
  String _getMasterName(String masterId) {
    final master = _masters.firstWhereOrNull((m) => m.id == masterId);
    return master?.displayName ?? 'Unknown Master';
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('analytics')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localizations.translate('overview')),
              Tab(text: localizations.translate('services')),
              Tab(text: localizations.translate('masters')),
            ],
          ),
        ),
        body: Column(
          children: [
            // Period selection
            _buildPeriodSelector(),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview Tab
                  _buildOverviewTab(),
                  
                  // Services Tab
                  _buildServicesTab(),
                  
                  // Masters Tab
                  _buildMastersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Period selector widget
  Widget _buildPeriodSelector() {
    final localizations = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('select_period'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip('week', localizations.translate('last_week')),
                const SizedBox(width: 8),
                _buildPeriodChip('month', localizations.translate('last_month')),
                const SizedBox(width: 8),
                _buildPeriodChip('year', localizations.translate('last_year')),
                const SizedBox(width: 8),
                ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 16,
                        color: _selectedPeriod == 'custom'
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(localizations.translate('custom')),
                    ],
                  ),
                  backgroundColor: _selectedPeriod == 'custom'
                      ? Theme.of(context).primaryColor
                      : null,
                  labelStyle: TextStyle(
                    color: _selectedPeriod == 'custom'
                        ? Colors.white
                        : null,
                  ),
                  onPressed: _selectDateRange,
                ),
              ],
            ),
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Period selection chip
  Widget _buildPeriodChip(String period, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedPeriod == period,
      onSelected: (selected) {
        if (selected) {
          _changePeriod(period);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: _selectedPeriod == period ? Colors.white : Colors.black,
      ),
    );
  }
  
  // Overview tab content
  Widget _buildOverviewTab() {
    final localizations = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₸ ', decimalDigits: 0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key metrics cards
          Row(
            children: [
              _buildMetricCard(
                title: localizations.translate('total_appointments'),
                value: _totalAppointments.toString(),
                icon: Icons.calendar_today,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: localizations.translate('total_revenue'),
                value: currencyFormat.format(_totalRevenue),
                icon: Icons.monetization_on,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(
                title: localizations.translate('completion_rate'),
                value: '${_completionRate.toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: Colors.purple,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: localizations.translate('cancelled'),
                value: _cancelledAppointments.toString(),
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ],
          ),
          
          // Revenue trend chart
          const SizedBox(height: 24),
          Text(
            localizations.translate('revenue_trend'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildRevenueChart(),
          ),
          
          // Appointments status distribution
          const SizedBox(height: 24),
          Text(
            localizations.translate('appointment_status'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildAppointmentStatusChart(),
          ),
        ],
      ),
    );
  }
  
  // Metric card widget
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Revenue chart widget
  Widget _buildRevenueChart() {
    // Group appointments by date and calculate daily revenue
    final Map<DateTime, double> dailyRevenue = {};
    
    for (final appointment in _currentPeriodAppointments) {
      if (appointment.status == 'completed') {
        final date = DateTime(
          appointment.date.year,
          appointment.date.month,
          appointment.date.day,
        );
        
        dailyRevenue[date] = (dailyRevenue[date] ?? 0) + appointment.price;
      }
    }
    
    // Sort dates and prepare chart data
    final sortedDates = dailyRevenue.keys.toList()..sort();
    
    // If no data, show placeholder
    if (sortedDates.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_data_available'),
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Create chart data points
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyRevenue[sortedDates[i]]!));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Show date for some points to avoid overcrowding
                if (sortedDates.length <= 7 || value % (sortedDates.length ~/ 5 + 1) == 0) {
                  if (value.toInt() < sortedDates.length) {
                    final date = sortedDates[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  // Appointment status pie chart
  Widget _buildAppointmentStatusChart() {
    // Count appointments by status
    final Map<String, int> statusCounts = {
      'completed': 0,
      'cancelled': 0,
      'booked': 0,
      'no-show': 0,
    };
    
    for (final appointment in _currentPeriodAppointments) {
      statusCounts[appointment.status] = (statusCounts[appointment.status] ?? 0) + 1;
    }
    
    // If no data, show placeholder
    if (_currentPeriodAppointments.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_data_available'),
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Colors for different statuses
    final statusColors = {
      'completed': Colors.green,
      'cancelled': Colors.red,
      'booked': Colors.blue,
      'no-show': Colors.orange,
    };
    
    // Status labels
    final statusLabels = {
      'completed': AppLocalizations.of(context).translate('completed'),
      'cancelled': AppLocalizations.of(context).translate('cancelled'),
      'booked': AppLocalizations.of(context).translate('booked'),
      'no-show': AppLocalizations.of(context).translate('no-show'),
    };
    
    return Row(
      children: [
        // Pie chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: statusCounts.entries.map((entry) {
                final status = entry.key;
                final count = entry.value;
                final percentage = _totalAppointments > 0
                    ? (count / _totalAppointments) * 100
                    : 0;
                
                return PieChartSectionData(
                  color: statusColors[status] ?? Colors.grey,
                  value: count.toDouble(),
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        
        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: statusCounts.entries.map((entry) {
              final status = entry.key;
              final count = entry.value;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColors[status] ?? Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${statusLabels[status] ?? status}: $count',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  // Services tab content
  Widget _buildServicesTab() {
    final localizations = AppLocalizations.of(context);
    
    // Calculate service metrics
    final serviceStats = _calculateServiceStats();
    
    // Sort services by appointment count
    serviceStats.sort((a, b) => b['count'].compareTo(a['count']));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services popularity chart
          Text(
            localizations.translate('popular_services'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildServicesChart(serviceStats),
          ),
          
          // Services table
          const SizedBox(height: 24),
          Text(
            localizations.translate('services_performance'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildServicesTable(serviceStats),
        ],
      ),
    );
  }
  
  // Calculate service statistics
  List<Map<String, dynamic>> _calculateServiceStats() {
    // Map to store service stats
    final Map<String, Map<String, dynamic>> serviceStatsMap = {};
    
    // Process appointments
    for (final appointment in _currentPeriodAppointments) {
      final serviceId = appointment.serviceId;
      
      // Skip if service not found
      if (!serviceStatsMap.containsKey(serviceId)) {
        final serviceName = _getServiceName(serviceId);
        serviceStatsMap[serviceId] = {
          'id': serviceId,
          'name': serviceName,
          'count': 0,
          'completed': 0,
          'cancelled': 0,
          'revenue': 0.0,
        };
      }
      
      // Update counts
      serviceStatsMap[serviceId]!['count'] = serviceStatsMap[serviceId]!['count'] + 1;
      
      if (appointment.status == 'completed') {
        serviceStatsMap[serviceId]!['completed'] = serviceStatsMap[serviceId]!['completed'] + 1;
        serviceStatsMap[serviceId]!['revenue'] = serviceStatsMap[serviceId]!['revenue'] + appointment.price;
      } else if (appointment.status == 'cancelled') {
        serviceStatsMap[serviceId]!['cancelled'] = serviceStatsMap[serviceId]!['cancelled'] + 1;
      }
    }
    
    // Convert map to list
    return serviceStatsMap.values.toList();
  }
  
  // Services horizontal bar chart
  Widget _buildServicesChart(List<Map<String, dynamic>> serviceStats) {
    // If no data, show placeholder
    if (serviceStats.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_data_available'),
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Take top 5 services
    final topServices = serviceStats.take(5).toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topServices.isNotEmpty ? topServices.map((s) => s['count'] as int).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < topServices.length) {
                  final service = topServices[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _truncateString(service['name'], 10),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(topServices.length, (index) {
          final service = topServices[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: service['count'].toDouble(),
                color: Theme.of(context).primaryColor,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  // Services performance table
  Widget _buildServicesTable(List<Map<String, dynamic>> serviceStats) {
    final localizations = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₸ ', decimalDigits: 0);
    
    if (serviceStats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            localizations.translate('no_data_available'),
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(localizations.translate('service'))),
          DataColumn(label: Text(localizations.translate('appointments'))),
          DataColumn(label: Text(localizations.translate('completed'))),
          DataColumn(label: Text(localizations.translate('cancelled'))),
          DataColumn(label: Text(localizations.translate('revenue'))),
        ],
        rows: serviceStats.map((service) {
          return DataRow(
            cells: [
              DataCell(Text(service['name'])),
              DataCell(Text(service['count'].toString())),
              DataCell(Text(service['completed'].toString())),
              DataCell(Text(service['cancelled'].toString())),
              DataCell(Text(currencyFormat.format(service['revenue']))),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  // Masters tab content
  Widget _buildMastersTab() {
    final localizations = AppLocalizations.of(context);
    
    // Calculate master metrics
    final masterStats = _calculateMasterStats();
    
    // Sort masters by appointment count
    masterStats.sort((a, b) => b['count'].compareTo(a['count']));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Masters performance chart
          Text(
            localizations.translate('top_masters'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildMastersChart(masterStats),
          ),
          
          // Masters table
          const SizedBox(height: 24),
          Text(
            localizations.translate('masters_performance'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildMastersTable(masterStats),
        ],
      ),
    );
  }
  
  // Calculate master statistics
  List<Map<String, dynamic>> _calculateMasterStats() {
    // Map to store master stats
    final Map<String, Map<String, dynamic>> masterStatsMap = {};
    
    // Process appointments
    for (final appointment in _currentPeriodAppointments) {
      final masterId = appointment.masterId;
      
      // Skip if master not found
      if (!masterStatsMap.containsKey(masterId)) {
        final masterName = _getMasterName(masterId);
        masterStatsMap[masterId] = {
          'id': masterId,
          'name': masterName,
          'count': 0,
          'completed': 0,
          'cancelled': 0,
          'revenue': 0.0,
        };
      }
      
      // Update counts
      masterStatsMap[masterId]!['count'] = masterStatsMap[masterId]!['count'] + 1;
      
      if (appointment.status == 'completed') {
        masterStatsMap[masterId]!['completed'] = masterStatsMap[masterId]!['completed'] + 1;
        masterStatsMap[masterId]!['revenue'] = masterStatsMap[masterId]!['revenue'] + appointment.price;
      } else if (appointment.status == 'cancelled') {
        masterStatsMap[masterId]!['cancelled'] = masterStatsMap[masterId]!['cancelled'] + 1;
      }
    }
    
    // Convert map to list
    return masterStatsMap.values.toList();
  }
  
  // Masters horizontal bar chart
  Widget _buildMastersChart(List<Map<String, dynamic>> masterStats) {
    // If no data, show placeholder
    if (masterStats.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_data_available'),
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Take top 5 masters
    final topMasters = masterStats.take(5).toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topMasters.isNotEmpty ? topMasters.map((s) => s['count'] as int).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < topMasters.length) {
                  final master = topMasters[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _truncateString(master['name'], 10),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(topMasters.length, (index) {
          final master = topMasters[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: master['count'].toDouble(),
                color: Colors.orange,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  // Masters performance table
  Widget _buildMastersTable(List<Map<String, dynamic>> masterStats) {
    final localizations = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₸ ', decimalDigits: 0);
    
    if (masterStats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            localizations.translate('no_data_available'),
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(localizations.translate('master'))),
          DataColumn(label: Text(localizations.translate('appointments'))),
          DataColumn(label: Text(localizations.translate('completed'))),
          DataColumn(label: Text(localizations.translate('cancelled'))),
          DataColumn(label: Text(localizations.translate('revenue'))),
        ],
        rows: masterStats.map((master) {
          return DataRow(
            cells: [
              DataCell(Text(master['name'])),
              DataCell(Text(master['count'].toString())),
              DataCell(Text(master['completed'].toString())),
              DataCell(Text(master['cancelled'].toString())),
              DataCell(Text(currencyFormat.format(master['revenue']))),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  // Helper method to truncate long strings
  String _truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}