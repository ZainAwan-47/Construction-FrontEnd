import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/navigation/role_bottom_nav.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final state = AppState();

        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Project Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Gulshan Villa · Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                if (state.pendingReviewCount > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${state.pendingReviewCount} expenses pending your review.',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.reviewQueueRoute,
                          ),
                          child: const Text(
                            'Review Now',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    MetricCard(
                      label: 'Total Budget',
                      amount: state.totalProjectBudget,
                      icon: Icons.account_balance,
                    ),
                    MetricCard(
                      label: 'Total Spent',
                      amount: state.totalApprovedExpenses,
                      icon: Icons.shopping_cart_checkout,
                      iconColor: AppColors.success,
                    ),
                    MetricCard(
                      label: 'Remaining Budget',
                      amount: state.remainingProjectBudget,
                      icon: Icons.pie_chart_outline,
                    ),
                    MetricCard(
                      label: 'Contractor Cash',
                      amount: state.contractorCashInHand,
                      icon: Icons.wallet,
                      isHighlighted: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    QuickActionCard(
                      title: 'Send Funds',
                      subtitle: 'Top up contractor',
                      icon: Icons.send_rounded,
                      isPrimary: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.sendFundsRoute,
                      ),
                    ),
                    QuickActionCard(
                      title: 'Review Queue',
                      subtitle: '${state.pendingReviewCount} pending',
                      icon: Icons.fact_check_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.reviewQueueRoute,
                      ),
                    ),
                    QuickActionCard(
                      title: 'Milestones',
                      subtitle: 'Phase tracking',
                      icon: Icons.analytics_outlined,
                      // PHASE 8: Wired to MilestoneTracker
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.milestoneTrackerRoute,
                      ),
                    ),
                    QuickActionCard(
                      title: 'Final Report',
                      subtitle: 'PDF generation',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.placeholderRoute,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: RoleBottomNav(
            role: state.activeRole,
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushNamed(context, AppRouter.sendFundsRoute);
              } else if (index == 2) {
                Navigator.pushNamed(context, AppRouter.reviewQueueRoute);
              } else if (index == 3) {
                // PHASE 8: Wired to MilestoneTracker
                Navigator.pushNamed(context, AppRouter.milestoneTrackerRoute);
              } else if (index != 0) {
                Navigator.pushNamed(context, AppRouter.placeholderRoute);
              }
            },
          ),
        );
      },
    );
  }
}