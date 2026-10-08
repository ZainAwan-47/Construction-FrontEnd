import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';
import '../../models/expense.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({Key? key, required this.expenseId}) : super(key: key);

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _feedbackController = TextEditingController();

  String _formatCurrency(double value) {
    return formatPkrCurrency(value);
  }

  void _approveExpense(Expense expense) {
    if (!AppState().approveExpense(expense.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense was not approved. Check its status and active role.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense Approved. Financials updated.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _disputeExpense(Expense expense) {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute reason is required.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (!AppState().disputeExpense(expense.id, _feedbackController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense was not disputed. Check its status and active role.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense Disputed. Returned to contractor.'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Listen dynamically so UI locks if status changes externally
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, child) {
        final expense = AppState().allExpenses.firstWhere(
          (e) => e.id == widget.expenseId,
          orElse: () => throw Exception('Expense not found'),
        );

        final isPending = expense.status == ExpenseStatus.pending;

        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(
            title: const Text('Expense Details'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPending ? AppColors.warning.withOpacity(0.1) : (expense.status == ExpenseStatus.approved ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPending ? AppColors.warning : (expense.status == ExpenseStatus.approved ? AppColors.success : AppColors.error),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPending ? Icons.hourglass_empty : (expense.status == ExpenseStatus.approved ? Icons.lock_outline : Icons.error_outline),
                          color: isPending ? AppColors.warning : (expense.status == ExpenseStatus.approved ? AppColors.success : AppColors.error),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isPending ? 'Pending Review' : (expense.status == ExpenseStatus.approved ? 'Approved & Locked' : 'Disputed'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isPending ? AppColors.warning : (expense.status == ExpenseStatus.approved ? AppColors.success : AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Description', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(expense.description, style: const TextStyle(fontSize: 18, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        const Divider(height: 32),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(expense.category, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Amount', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(_formatCurrency(expense.amount), style: const TextStyle(fontSize: 18, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        
                        const Text('Date Submitted', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${expense.date.day}/${expense.date.month}/${expense.date.year}', style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Receipt Mock
                  const Text('Attached Demo Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          expense.receiptAttached ? Icons.receipt_long : Icons.image_not_supported_outlined,
                          size: 40,
                          color: expense.receiptAttached ? AppColors.primaryBlue : AppColors.hint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          expense.receiptAttached ? 'Demo receipt attached' : 'No demo receipt attached',
                          style: TextStyle(
                            color: expense.receiptAttached ? AppColors.primaryBlue : AppColors.hint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feedback & Actions (Dynamic based on status)
                  if (isPending) ...[
                    const Text('Review Decision', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Reason for dispute (Required if disputing)',
                        filled: true,
                        fillColor: AppColors.surfaceWhite,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _disputeExpense(expense),
                            icon: const Icon(Icons.error_outline),
                            label: const Text('Dispute'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveExpense(expense),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // PHASE 7: History List implementation replacing single feedback string
                  ] else if (expense.feedbackHistory.isNotEmpty) ...[
                    const Text('Dispute History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: expense.feedbackHistory.asMap().entries.map((entry) {
                          final index = entry.key;
                          final text = entry.value;
                          final isLatest = index == expense.feedbackHistory.length - 1;
                          
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLatest ? 0 : 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLatest ? 'Latest Feedback' : 'Previous Feedback ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w800, 
                                    color: isLatest ? AppColors.error : AppColors.hint
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  text, 
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40), // Safe scroll area
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}