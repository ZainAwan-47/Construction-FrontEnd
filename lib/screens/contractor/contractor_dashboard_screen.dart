import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/navigation/role_bottom_nav.dart';

class ContractorDashboardScreen extends StatelessWidget {
  const ContractorDashboardScreen({Key? key}) : super(key: key);

  // Native Dart currency formatter without requiring 'intl' package
  String _formatCurrency(double value) {
    String result = value.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    return 'PKR ${result.replaceAllMapped(reg, mathFunc)}';
  }

  @override
  Widget build(BuildContext context) {
    // Native local state access
    final state = AppState();

    return Scaffold(
      backgroundColor: AppColors.surfaceWarmGray,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Site Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Gulshan Villa · Active', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            if (state.unconfirmedIncomingFunds > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.download_rounded, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text('Incoming Transfer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatCurrency(state.unconfirmedIncomingFunds),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryBlue, letterSpacing: -1.0),
                    ),
                    const SizedBox(height: 4),
                    const Text('Awaiting your confirmation to enter Cash-in-Hand.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.placeholderRoute),
                        child: const Text('Confirm Receipt'),
                      ),
                    ),
                  ],
                ),
              ),

            const Text('Working Capital', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
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

            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
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
                  title: 'New Expense',
                  subtitle: 'Upload receipt',
                  icon: Icons.add_a_photo_outlined,
                  isPrimary: true,
                  onTap: () => Navigator.pushNamed(context, AppRouter.placeholderRoute),
                ),
                QuickActionCard(
                  title: 'My Expenses',
                  subtitle: 'View history',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRouter.placeholderRoute),
                ),
                QuickActionCard(
                  title: 'Milestones',
                  subtitle: 'Phase progress',
                  icon: Icons.analytics_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRouter.placeholderRoute),
                ),
                QuickActionCard(
                  title: 'Settings',
                  subtitle: 'Preferences',
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRouter.placeholderRoute),
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
          if (index != 0) Navigator.pushNamed(context, AppRouter.placeholderRoute);
        },
      ),
    );
  }
}