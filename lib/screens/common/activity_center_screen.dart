import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/activity_entry.dart';
import '../../state/app_state.dart';

class ActivityCenterScreen extends StatelessWidget {
  const ActivityCenterScreen({super.key});

  IconData _iconFor(ActivityType type) {
    switch (type) {
      case ActivityType.expenseSubmitted:
        return Icons.receipt_long_outlined;
      case ActivityType.expenseApproved:
        return Icons.check_circle_outline;
      case ActivityType.expenseDisputed:
        return Icons.report_gmailerrorred_outlined;
      case ActivityType.expenseResubmitted:
        return Icons.refresh_outlined;
      case ActivityType.transferConfirmed:
        return Icons.account_balance_wallet_outlined;
      case ActivityType.milestoneSignedOff:
        return Icons.fact_check_outlined;
      case ActivityType.inspectionRecorded:
        return Icons.home_work_outlined;
      case ActivityType.projectCompleted:
        return Icons.handshake_outlined;
    }
  }

  String _timestamp(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${date.day}/${date.month}/${date.year} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final entries = AppState().activityEntries;
        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(title: const Text('Activity')),
          body: entries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: AppColors.primaryBlue,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'You’re all caught up',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Project updates will appear here after an action is completed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconFor(entry.type),
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.description,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _timestamp(entry.occurredAt),
                                  style: const TextStyle(
                                    color: AppColors.hint,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
