import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../models/expense.dart';

class MyExpensesScreen extends StatelessWidget {
  const MyExpensesScreen({Key? key}) : super(key: key);

  String _formatCurrency(double value) {
    String result = value.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    return 'PKR ${result.replaceAllMapped(reg, mathFunc)}';
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
    return Scaffold(
      backgroundColor: AppColors.surfaceWarmGray,
      appBar: AppBar(title: const Text('My Expenses')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: AppState(),
          builder: (context, _) {
            final expenses = AppState().allExpenses;
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final isDisputed = expense.status == ExpenseStatus.disputed;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
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
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.hint),
                            const SizedBox(width: 6),
                            Text(
                              '${expense.date.day}/${expense.date.month}/${expense.date.year}', 
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)
                            ),
                            const Spacer(),
                            if (expense.receiptAttached)
                              Row(
                                children: const [
                                  Icon(Icons.attachment, size: 14, color: AppColors.primaryBlue),
                                  SizedBox(width: 4),
                                  Text('Receipt attached', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                                ],
                              )
                          ],
                        ),
                        // --- PHASE 7: DISPUTED EXPENSE ADJUSTMENT UI ---
                        if (isDisputed && expense.feedbackHistory.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.feedback_outlined, size: 14, color: AppColors.error),
                                    SizedBox(width: 4),
                                    Text('Latest Owner Feedback', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  expense.feedbackHistory.last,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRouter.adjustExpenseRoute, arguments: expense.id);
                              },
                              icon: const Icon(Icons.edit_document),
                              label: const Text('Adjust & Resubmit'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }
}