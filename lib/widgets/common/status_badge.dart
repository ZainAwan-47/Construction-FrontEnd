import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeStatus { pending, approved, disputed, info }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String text;

  const StatusBadge({super.key, required this.status, required this.text});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color foregroundColor;
    switch (status) {
      case BadgeStatus.pending:
        bgColor = AppColors.warning;
        foregroundColor = AppColors.textPrimary;
        break;
      case BadgeStatus.approved:
        bgColor = AppColors.success;
        foregroundColor = Colors.white;
        break;
      case BadgeStatus.disputed:
        bgColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
      case BadgeStatus.info:
        bgColor = AppColors.info;
        foregroundColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
