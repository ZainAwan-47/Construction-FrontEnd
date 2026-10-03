import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../models/milestone.dart';

class MilestoneTrackerScreen extends StatelessWidget {
  const MilestoneTrackerScreen({Key? key}) : super(key: key);

  Widget _buildStatusIndicator(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        );
      case MilestoneStatus.awaitingSignOff:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
        );
      case MilestoneStatus.inProgress:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.construction, color: AppColors.primaryOrange, size: 20),
        );
      case MilestoneStatus.locked:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_outline, color: AppColors.hint, size: 20),
        );
    }
  }

  String _statusLabel(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return 'Completed';
      case MilestoneStatus.awaitingSignOff:
        return 'Awaiting Sign-Off';
      case MilestoneStatus.inProgress:
        return 'In Progress';
      case MilestoneStatus.locked:
        return 'Locked';
    }
  }

  Color _statusColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return AppColors.success;
      case MilestoneStatus.awaitingSignOff:
        return AppColors.warning;
      case MilestoneStatus.inProgress:
        return AppColors.primaryOrange;
      case MilestoneStatus.locked:
        return AppColors.hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWarmGray,
      appBar: AppBar(
        title: const Text('Milestones'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: AppState(),
          builder: (context, _) {
            final state = AppState();
            final milestones = state.allMilestones;
            final completedCount = state.completedMilestoneCount;
            final progressFraction = completedCount / 6.0;

            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text(
                  'Project Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completedCount of 6 Phases Completed',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(progressFraction * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Construction Phases',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                ...milestones.map((m) {
                  final isLocked = m.status == MilestoneStatus.locked;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: isLocked ? 0 : 2,
                    color: isLocked ? AppColors.surfaceWhite.withOpacity(0.6) : AppColors.surfaceWhite,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.milestoneDetailRoute,
                          arguments: m.id,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _buildStatusIndicator(m.status),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Phase ${m.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isLocked ? AppColors.hint : AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _statusLabel(m.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(m.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isLocked ? AppColors.hint : AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: isLocked ? AppColors.hint : AppColors.primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}