import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expense.dart';

enum BadgeStatus { pending, approved, disputed, info }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String text;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.status,
    required this.text,
    this.icon,
  });

  factory StatusBadge.forExpense(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return const StatusBadge(
          status: BadgeStatus.pending,
          text: 'Pending',
          icon: Icons.hourglass_empty,
        );
      case ExpenseStatus.approved:
        return const StatusBadge(
          status: BadgeStatus.approved,
          text: 'Approved',
          icon: Icons.check_circle_outline,
        );
      case ExpenseStatus.disputed:
        return const StatusBadge(
          status: BadgeStatus.disputed,
          text: 'Disputed',
          icon: Icons.error_outline,
        );
    }
  }

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
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 9 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: icon == null
          ? Text(
              text,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: foregroundColor),
                const SizedBox(width: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }
}
