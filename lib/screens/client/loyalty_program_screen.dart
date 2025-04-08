// lib/screens/client/loyalty_program_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/loyalty_transaction_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/loyalty_service.dart';
import '../../../widgets/loading_overlay.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  int _loyaltyPoints = 0;
  List<LoyaltyTransactionModel> _transactions = [];
  List<Map<String, dynamic>> _availablePromotions = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLoyaltyData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Загрузка данных программы лояльности
  Future<void> _loadLoyaltyData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loyaltyService = LoyaltyService();
      
      final user = authService.currentUserModel;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Получаем баллы лояльности
      _loyaltyPoints = user.loyaltyPoints;
      
      // Получаем историю транзакций
      final transactions = await loyaltyService.getUserTransactions(user.id);
      
      // Получаем доступные акции
      final promotions = await loyaltyService.getAvailablePromotions();
      
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _availablePromotions = promotions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке данных программы лояльности: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке данных программы лояльности: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('loyalty_program')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localizations.translate('points_history')),
              Tab(text: localizations.translate('available_promotions')),
            ],
          ),
        ),
        body: Column(
          children: [
            // Верхняя часть с информацией о баллах
            _buildPointsInfo(context),
            
            // Содержимое вкладок
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Вкладка с историей баллов
                  _buildPointsHistoryTab(context),
                  
                  // Вкладка с доступными акциями
                  _buildPromotionsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Верхняя часть с информацией о баллах
  Widget _buildPointsInfo(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        children: [
          Text(
            localizations.translate('earned_points'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _loyaltyPoints.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPointsDescription(_loyaltyPoints),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Вкладка с историей баллов
  Widget _buildPointsHistoryTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_points_history'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadLoyaltyData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return _buildTransactionItem(context, transaction);
        },
      ),
    );
  }
  
  // Элемент истории транзакций
  Widget _buildTransactionItem(BuildContext context, LoyaltyTransactionModel transaction) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(transaction.date);
    
    // Иконка и цвет в зависимости от типа транзакции
    IconData icon;
    Color color;
    
    switch (transaction.type) {
      case 'earn':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'redeem':
        icon = Icons.remove_circle;
        color = Colors.red;
        break;
      case 'bonus':
        icon = Icons.card_giftcard;
        color = Colors.amber;
        break;
      default:
        icon = Icons.swap_horiz;
        color = Colors.blue;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.description),
        subtitle: Text(formattedDate),
        trailing: Text(
          transaction.points > 0 ? '+${transaction.points}' : '${transaction.points}',
          style: TextStyle(
            color: transaction.points > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  // Вкладка с доступными акциями
  Widget _buildPromotionsTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (_availablePromotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_available_promotions'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availablePromotions.length,
      itemBuilder: (context, index) {
        final promotion = _availablePromotions[index];
        return _buildPromotionItem(context, promotion);
      },
    );
  }
  
  // Элемент акции
  Widget _buildPromotionItem(BuildContext context, Map<String, dynamic> promotion) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    
    // Получаем локализованное название и описание
    final title = promotion['title'][languageCode] ?? promotion['title']['ru'] ?? '';
    final description = promotion['description'][languageCode] ?? promotion['description']['ru'] ?? '';
    
    // Формируем дату окончания акции, если есть
    String validUntil = '';
    if (promotion['endDate'] != null) {
      final endDate = promotion['endDate'] is DateTime 
          ? promotion['endDate'] 
          : DateTime.fromMillisecondsSinceEpoch(promotion['endDate']);
      final dateFormat = DateFormat('dd.MM.yyyy');
      validUntil = '${localizations.translate('valid_until')}: ${dateFormat.format(endDate)}';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            if (validUntil.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                validUntil,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Стоимость в баллах
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${promotion['points'] ?? 0} ${localizations.translate('points')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Кнопка использования
                ElevatedButton(
                  onPressed: _loyaltyPoints >= (promotion['points'] ?? 0)
                      ? () => _redeemPromotion(promotion)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations.translate('redeem')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Метод для получения текстового описания баллов
  String _getPointsDescription(int points) {
    final localizations = AppLocalizations.of(context);
    
    if (points < 100) {
      return localizations.translate('loyalty_level_basic');
    } else if (points < 300) {
      return localizations.translate('loyalty_level_silver');
    } else if (points < 1000) {
      return localizations.translate('loyalty_level_gold');
    } else {
      return localizations.translate('loyalty_level_platinum');
    }
  }
  
  // Метод для использования акции
  Future<void> _redeemPromotion(Map<String, dynamic> promotion) async {
    final localizations = AppLocalizations.of(context);
    
    // Проверяем, достаточно ли баллов
    if (_loyaltyPoints < (promotion['points'] ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('not_enough_points')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    // Показываем диалог подтверждения
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('redeem_promotion')),
        content: Text(
          '${localizations.translate('confirm_redeem_promotion')}\n'
          '${promotion['title'][Localizations.localeOf(context).languageCode] ?? promotion['title']['ru'] ?? ''}\n'
          '${localizations.translate('for')} ${promotion['points']} ${localizations.translate('points')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.translate('confirm')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loyaltyService = LoyaltyService();
      
      final user = authService.currentUserModel;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Использовать акцию
      final success = await loyaltyService.redeemPromotion(
        userId: user.id,
        promotionId: promotion['id'],
        points: promotion['points'] ?? 0,
      );
      
      if (success) {
        // Обновляем данные
        await _loadLoyaltyData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('promotion_redeemed')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to redeem promotion');
      }
    } catch (e) {
      debugPrint('Ошибка при использовании акции: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при использовании акции: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}