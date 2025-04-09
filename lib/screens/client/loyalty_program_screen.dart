// lib/screens/client/loyalty_program_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/loyalty_transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/loyalty_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/loyalty_badge.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LoyaltyService _loyaltyService = LoyaltyService();
  
  bool _isLoading = true;
  int _loyaltyPoints = 0;
  List<LoyaltyTransactionModel> _transactions = [];
  List<Map<String, dynamic>> _availablePromotions = [];
  List<Map<String, dynamic>> _redeemedPromotions = []; // Track redeemed promotions
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Added a tab for redeemed promotions
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
      final user = authService.currentUserModel;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get real-time point count from the service instead of the user model
      final points = await _loyaltyService.getUserPoints(user.id);
      
      // Get transaction history
      final transactions = await _loyaltyService.getUserTransactions(user.id);
      
      // Get available promotions
      final promotions = await _loyaltyService.getAvailablePromotions();
      
      // Get redeemed promotions
      final redeemed = await _loyaltyService.getUserRedeemedPromotions(user.id);
      
      if (mounted) {
        setState(() {
          _loyaltyPoints = points;
          _transactions = transactions;
          _availablePromotions = promotions;
          _redeemedPromotions = redeemed;
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
              Tab(text: localizations.translate('my_promotions')), // New tab
            ],
          ),
        ),
        body: Column(
          children: [
            // Points information card at the top
            _buildPointsInfo(context),
            
            // Tab content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Points history tab
                  _buildPointsHistoryTab(context),
                  
                  // Available promotions tab
                  _buildPromotionsTab(context),
                  
                  // My redeemed promotions tab
                  _buildRedeemedPromotionsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Points information card
  Widget _buildPointsInfo(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.translate('earned_points'),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                LoyaltyBadge(points: _loyaltyPoints),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _loyaltyPoints.toString(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('points_earning_rule'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Points history tab
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
  
  // Transaction item
  Widget _buildTransactionItem(BuildContext context, LoyaltyTransactionModel transaction) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(transaction.date);
    
    // Icon and color based on transaction type
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
  
  // Available promotions tab
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
        return _buildPromotionItem(context, promotion, isRedeemed: false);
      },
    );
  }
  
  // My redeemed promotions tab
  Widget _buildRedeemedPromotionsTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (_redeemedPromotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_redeemed_promotions'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _redeemedPromotions.length,
      itemBuilder: (context, index) {
        final promotion = _redeemedPromotions[index];
        return _buildPromotionItem(context, promotion, isRedeemed: true);
      },
    );
  }
  
  // Promotion item card
  Widget _buildPromotionItem(BuildContext context, Map<String, dynamic> promotion, {required bool isRedeemed}) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    
    // Get localized title and description
    final title = promotion['title'][languageCode] ?? promotion['title']['ru'] ?? '';
    final description = promotion['description'][languageCode] ?? promotion['description']['ru'] ?? '';
    
    // Format expiration date if available
    String validUntil = '';
    if (promotion['endDate'] != null) {
      final endDate = promotion['endDate'] is DateTime 
          ? promotion['endDate'] 
          : DateTime.fromMillisecondsSinceEpoch(promotion['endDate']);
      final dateFormat = DateFormat('dd.MM.yyyy');
      validUntil = '${localizations.translate('valid_until')}: ${dateFormat.format(endDate)}';
    }
    
    // Format redemption date for redeemed promotions
    String redeemedDate = '';
    if (isRedeemed && promotion['redeemedAt'] != null) {
      final date = promotion['redeemedAt'] is DateTime 
          ? promotion['redeemedAt'] 
          : DateTime.fromMillisecondsSinceEpoch(promotion['redeemedAt']);
      final dateFormat = DateFormat('dd.MM.yyyy');
      redeemedDate = '${localizations.translate('redeemed_on')}: ${dateFormat.format(date)}';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRedeemed 
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2) 
            : BorderSide.none,
      ),
      elevation: isRedeemed ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isRedeemed ? Icons.check_circle : Icons.local_offer,
                  color: isRedeemed ? Colors.green : Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isRedeemed ? Colors.green : null,
                    ),
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
            if (redeemedDate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                redeemedDate,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Bottom section with points and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Points cost
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
                
                // Action button (redeem or use)
                if (!isRedeemed)
                  ElevatedButton(
                    onPressed: _loyaltyPoints >= (promotion['points'] ?? 0)
                        ? () => _redeemPromotion(promotion)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(localizations.translate('redeem')),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _useRedeemedPromotion(promotion),
                    icon: Icon(Icons.redeem),
                    label: Text(localizations.translate('use_promotion')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Redeem a promotion
  Future<void> _redeemPromotion(Map<String, dynamic> promotion) async {
    final localizations = AppLocalizations.of(context);
    
    // Check if enough points
    if (_loyaltyPoints < (promotion['points'] ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('not_enough_points')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    // Show confirmation dialog
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
      
      final user = authService.currentUserModel;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Redeem promotion
      final success = await _loyaltyService.redeemPromotion(
        userId: user.id,
        promotionId: promotion['id'],
        points: promotion['points'] ?? 0,
      );
      
      if (success) {
        // Refresh data
        await _loadLoyaltyData();
        
        // Switch to "My Promotions" tab
        _tabController.animateTo(2);
        
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
  
  // Use a redeemed promotion
  Future<void> _useRedeemedPromotion(Map<String, dynamic> promotion) async {
    final localizations = AppLocalizations.of(context);
    
    // Generate QR code or barcode to show at salon
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('use_promotion')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Promotion details
            Text(
              '${promotion['title'][Localizations.localeOf(context).languageCode] ?? promotion['title']['ru'] ?? ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Promotion code
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                promotion['promoCode'] ?? promotion['id'].substring(0, 8).toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Placeholder QR Code (in real app, generate actual QR code)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 160,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Instructions
            Text(
              localizations.translate('show_to_salon_staff'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.translate('close')),
          ),
        ],
      ),
    );
  }
}