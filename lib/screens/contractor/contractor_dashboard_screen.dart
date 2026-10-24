import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/navigation/role_bottom_nav.dart';
import '../../widgets/navigation/activity_notification_button.dart';
import '../../widgets/navigation/dashboard_tab_back_button.dart';
import '../../widgets/navigation/animated_tab_stack.dart';
import '../../screens/contractor/my_expenses_screen.dart';
import '../../widgets/common/milestone_tracker_screen.dart';
import '../../screens/common/settings_screen.dart';

class _ContractorHomeTab extends StatelessWidget {
  const _ContractorHomeTab();

  String _formatCurrency(double value) {
    return formatPkrCurrency(value);
  }

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
                  'Site Operations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Gulshan Villa · Active (Contractor)',
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
                if (state.pendingTransfers.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.download_rounded,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Incoming Transfer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatCurrency(state.pendingTransfers.first.amount),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ref: ${state.pendingTransfers.first.reference}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Awaiting your confirmation to enter Cash-in-Hand.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final confirmed = state.confirmTransfer(
                                state.pendingTransfers.first.id,
                              );
                              if (!confirmed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Transfer was not confirmed. Check its status and active role.',
                                    ),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funds confirmed. Cash-in-Hand updated.',
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text('Confirm Receipt'),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Working Capital',
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
                      label: 'Cash-in-Hand',
                      amount: state.contractorCashInHand,
                      icon: Icons.account_balance_wallet,
                      isHighlighted: true,
                    ),
                    MetricCard(
                      label: 'Approved Outflow',
                      amount: state.totalApprovedExpenses,
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.success,
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
                      title: 'New Expense',
                      subtitle: 'Upload receipt',
                      icon: Icons.add_a_photo_outlined,
                      isPrimary: true,
                      onTap: () => AppRouter.pushNamedOnce(
                        context,
                        AppRouter.createExpenseRoute,
                      ),
                    ),
                    QuickActionCard(
                      title: 'Handover Status',
                      subtitle: state.isProjectCompleted
                          ? 'Project handover complete'
                          : '${state.handoverBlockers.length} outstanding items',
                      icon: Icons.handshake_outlined,
                      onTap: () => AppRouter.pushNamedOnce(
                        context,
                        AppRouter.finalInspectionRoute,
                      ),
                    ),
                    QuickActionCard(
                      title: 'Final Project Report',
                      subtitle: 'Review project records',
                      icon: Icons.description_outlined,
                      onTap: () => AppRouter.pushNamedOnce(
                        context,
                        AppRouter.finalProjectReportRoute,
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

class ContractorDashboardScreen extends StatefulWidget {
  const ContractorDashboardScreen({super.key});

  @override
  State<ContractorDashboardScreen> createState() =>
      _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> {
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
            children: const [
              _ContractorHomeTab(),
              MyExpensesScreen(),
              MilestoneTrackerScreen(),
              SettingsScreen(),
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
