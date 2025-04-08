// lib/widgets/loyalty_badge.dart

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LoyaltyBadge extends StatelessWidget {
  final int points;
  
  const LoyaltyBadge({super.key, required this.points});
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Определение уровня лояльности
    String level;
    Color color;
    IconData icon;
    
    if (points < 100) {
      level = localizations.translate('loyalty_level_basic');
      color = Colors.grey.shade400;
      icon = Icons.emoji_events_outlined;
    } else if (points < 300) {
      level = localizations.translate('loyalty_level_silver');
      color = Colors.grey.shade300;
      icon = Icons.emoji_events;
    } else if (points < 1000) {
      level = localizations.translate('loyalty_level_gold');
      color = Colors.amber;
      icon = Icons.workspace_premium;
    } else {
      level = localizations.translate('loyalty_level_platinum');
      color = Colors.blueGrey;
      icon = Icons.diamond;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            level,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}