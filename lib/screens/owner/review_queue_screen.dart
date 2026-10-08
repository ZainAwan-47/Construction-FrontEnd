import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../models/expense.dart';

class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({Key? key}) : super(key: key);

  String _formatCurrency(double value) {
    return formatPkrCurrency(value);
  }

  Widget _buildStatusBadge(ExpenseStatus status) {
    Color bgColor;
    String label;
    IconData icon;

    switch (status) {
      case ExpenseStatus.pending:
        bgColor = AppColors.warning; label = 'Pending'; icon = Icons.hourglass_empty; break;
      case ExpenseStatus.approved:
        bgColor = AppColors.success; label = 'Approved'; icon = Icons.check_circle_outline; break;
      case ExpenseStatus.disputed:
        bgColor = AppColors.error; label = 'Disputed'; icon = Icons.error_outline; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surfaceWarmGray,
        appBar: AppBar(
          title: const Text('Review Expenses'),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryOrange,
            labelColor: AppColors.surfaceWhite,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Disputed'),
            ],
          ),
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: AppState(),
            builder: (context, child) {
              final state = AppState();
              final pending = state.allExpenses.where((e) => e.status == ExpenseStatus.pending).toList();
              final approved = state.allExpenses.where((e) => e.status == ExpenseStatus.approved).toList();
              final disputed = state.allExpenses.where((e) => e.status == ExpenseStatus.disputed).toList();

              Widget buildList(List<Expense> list, String emptyMessage) {
                if (list.isEmpty) {
                  return Center(child: Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final expense = list[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            AppRouter.expenseDetailRoute, 
                            arguments: expense.id
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(expense.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  _buildStatusBadge(expense.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                expense.description,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(expense.amount),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryOrange),
                              ),
                              const Divider(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: AppColors.hint),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${expense.date.day}/${expense.date.month}/${expense.date.year}', 
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)
                                  ),
                                  const Spacer(),
                                  const Text('View Details', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryBlue),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return TabBarView(
                children: [
                  buildList(pending, 'No pending expenses to review.'),
                  buildList(approved, 'No approved expenses found.'),
                  buildList(disputed, 'No disputed expenses found.'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}