import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeStatus { pending, approved, disputed, info }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String text;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    switch (status) {
      case BadgeStatus.pending:
        bgColor = AppColors.warning;
        break;
      case BadgeStatus.approved:
        bgColor = AppColors.success;
        break;
      case BadgeStatus.disputed:
        bgColor = AppColors.error;
        break;
      case BadgeStatus.info:
        bgColor = AppColors.info;
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}