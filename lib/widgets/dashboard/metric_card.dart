import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color? iconColor;
  final bool isHighlighted;

  const MetricCard({
    Key? key,
    required this.label,
    required this.amount,
    required this.icon,
    this.iconColor,
    this.isHighlighted = false,
  }) : super(key: key);

  // Native Dart currency formatter without requiring 'intl' package
  String _formatCurrency(double value) {
    return formatPkrCurrency(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.lightOrange : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted ? Border.all(color: AppColors.primaryOrange.withOpacity(0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: isHighlighted ? AppColors.primaryOrange : AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}