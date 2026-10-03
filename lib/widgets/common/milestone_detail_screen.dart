import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';
import '../../models/user_role.dart';
import '../../models/milestone.dart';

class MilestoneDetailScreen extends StatelessWidget {
  final int milestoneId;

  const MilestoneDetailScreen({Key? key, required this.milestoneId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final state = AppState();
        final isOwner = state.activeRole == UserRole.owner || state.activeRole == UserRole.both;
        final milestone = state.allMilestones.firstWhere((m) => m.id == milestoneId);

        final isLocked = milestone.status == MilestoneStatus.locked;
        final isComplete = milestone.status == MilestoneStatus.completed;
        final isAwaitingSignOff = milestone.status == MilestoneStatus.awaitingSignOff;
        final inProgress = milestone.status == MilestoneStatus.inProgress;

        Color bannerColor;
        String bannerText;
        IconData bannerIcon;

        if (isComplete) {
          bannerColor = AppColors.success;
          bannerText = 'Completed & Signed Off';
          bannerIcon = Icons.check_circle;
        } else if (isAwaitingSignOff) {
          bannerColor = AppColors.warning;
          bannerText = 'Awaiting Owner Sign-Off';
          bannerIcon = Icons.pending_actions;
        } else if (inProgress) {
          bannerColor = AppColors.primaryOrange;
          bannerText = 'In Progress';
          bannerIcon = Icons.construction;
        } else {
          bannerColor = AppColors.hint;
          bannerText = 'Locked (Sequential Requirement)';
          bannerIcon = Icons.lock_outline;
        }

        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(
            title: Text('Phase $milestoneId Details'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bannerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bannerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(bannerIcon, color: bannerColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            bannerText,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: bannerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
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
                        Text(
                          'Phase $milestoneId',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          milestone.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const Divider(height: 28),
                        const Text(
                          'Deliverables & Requirements',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          milestone.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        if (isComplete && milestone.completedDate != null) ...[
                          const Divider(height: 28),
                          Row(
                            children: [
                              const Icon(Icons.verified, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text(
                                'Signed off on: ${milestone.completedDate!.day}/${milestone.completedDate!.month}/${milestone.completedDate!.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (isOwner) ...[
                    if (isAwaitingSignOff || inProgress)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            state.signOffMilestone(milestoneId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Milestone signed off. Next phase unlocked.'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Owner Sign-Off & Complete Phase'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        ),
                      )
                    else if (isComplete)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'This phase is fully signed off and permanently locked.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Locked. Previous phases must be completed before sign-off.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.hint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ] else ...[
                    if (inProgress)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            state.markMilestoneReady(milestoneId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Milestone marked ready for Owner sign-off.'),
                                backgroundColor: AppColors.warning,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: const Text('Mark Ready for Owner Sign-Off'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                        ),
                      )
                    else if (isAwaitingSignOff)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Marked ready. Awaiting Owner sign-off to proceed.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isComplete)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'This phase is completed and locked.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Locked. Complete previous phases first.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.hint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}