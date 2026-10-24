import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/navigation/role_bottom_nav.dart';
import '../../widgets/navigation/activity_notification_button.dart';
import '../../widgets/navigation/dashboard_tab_back_button.dart';
import '../../widgets/navigation/animated_tab_stack.dart';
import '../../screens/owner/send_funds_screen.dart';
import '../../screens/owner/review_queue_screen.dart';
import '../../widgets/common/milestone_tracker_screen.dart';
import '../../screens/common/settings_screen.dart';

class _OwnerHomeTab extends StatelessWidget {
  const _OwnerHomeTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final state = AppState();

        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(
            leading: const DashboardTabBackButton(),
            automaticallyImplyLeading: false,
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
              const ActivityNotificationButton(),
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
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: AppColors.textPrimary,
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
                QuickActionGrid(
                  children: [
                    QuickActionCard(
                      title: 'Final Report',
                      subtitle: 'Project outcomes and finances',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: () => AppRouter.pushNamedOnce(
                        context,
                        AppRouter.finalProjectReportRoute,
                      ),
                    ),
                    QuickActionCard(
                      title: 'Final Inspection',
                      subtitle: state.isProjectCompleted
                          ? 'Project handover complete'
                          : state.isReadyForHandover
                          ? 'Ready for inspection'
                          : '${state.handoverBlockers.length} outstanding items',
                      icon: Icons.fact_check_outlined,
                      onTap: () => AppRouter.pushNamedOnce(
                        context,
                        AppRouter.finalInspectionRoute,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;
  final List<int> _tabHistory = [];

  bool get _canGoBack => _selectedIndex != 0 || _tabHistory.isNotEmpty;

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _tabHistory.add(_selectedIndex);
      _selectedIndex = index;
    });
  }

  void _goBack() {
    if (!_canGoBack) return;
    setState(() {
      _selectedIndex = _tabHistory.isNotEmpty ? _tabHistory.removeLast() : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTabNavigation(
      canGoBack: _canGoBack,
      onBack: _goBack,
      child: PopScope(
        canPop: !_canGoBack,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _canGoBack) _goBack();
        },
        child: Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          body: AnimatedTabStack(
            index: _selectedIndex,
            children: [
              const _OwnerHomeTab(),
              SendFundsScreen(onSubmitted: () => _selectTab(0)),
              const ReviewQueueScreen(),
              const MilestoneTrackerScreen(),
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: RoleBottomNav(
            role: AppState().activeRole,
            currentIndex: _selectedIndex,
            onTap: _selectTab,
          ),
        ),
      ),
    );
  }
}
