import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';
import '../../models/expense.dart';

class AdjustDisputedExpenseScreen extends StatefulWidget {
  final String expenseId;
  const AdjustDisputedExpenseScreen({Key? key, required this.expenseId}) : super(key: key);

  @override
  State<AdjustDisputedExpenseScreen> createState() => _AdjustDisputedExpenseScreenState();
}

class _AdjustDisputedExpenseScreenState extends State<AdjustDisputedExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  bool _receiptAttached = false;
  bool _attemptedSubmit = false;

  final List<String> _categories = [
    'Materials',
    'Labor',
    'Electrical',
    'Plumbing',
    'Transport',
    'Equipment',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final expenses = AppState().allExpenses;
    final index = expenses.indexWhere((e) => e.id == widget.expenseId);
    if (index != -1) {
      final expense = expenses[index];
      _amountController = TextEditingController(text: expense.amount.toString());
      _descriptionController = TextEditingController(text: expense.description);
      _selectedCategory = expense.category;
      _receiptAttached = expense.receiptAttached;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _mockAttachReceipt() {
    setState(() => _receiptAttached = true);
  }

  void _resubmitExpense() {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState!.validate() && _receiptAttached && _selectedCategory != null) {
      final amount = parsePositivePkrAmount(_amountController.text);
      if (amount == null) return;

      final resubmitted = AppState().resubmitExpense(
        widget.expenseId,
        _selectedCategory!,
        amount,
        _descriptionController.text.trim(),
        _receiptAttached,
      );
      if (!resubmitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense was not resubmitted. Check its status and active role.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mock expense resubmitted to Owner Queue.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = AppState().allExpenses;
    final index = expenses.indexWhere((e) => e.id == widget.expenseId);

    if (index == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Adjust Expense')),
        body: const Center(child: Text('Expense not found.')),
      );
    }

    final expense = expenses[index];
    if (expense.status != ExpenseStatus.disputed) {
      return Scaffold(
        backgroundColor: AppColors.surfaceWarmGray,
        appBar: AppBar(title: const Text('Adjust Expense')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: AppColors.hint),
                const SizedBox(height: 16),
                const Text(
                  'This expense is not in disputed status and cannot be modified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Return'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceWarmGray,
      appBar: AppBar(title: const Text('Adjust Disputed Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dispute History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error),
                ),
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
                      final i = entry.key;
                      final text = entry.value;
                      final isLatest = i == expense.feedbackHistory.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLatest ? 0 : 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLatest ? 'Latest Feedback' : 'Previous Feedback ${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isLatest ? AppColors.error : AppColors.hint,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              text,
                              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Adjust Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (value) => value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (PKR)',
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (parsePositivePkrAmount(value) == null) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description / Details',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: Icon(Icons.description_outlined),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Please provide a description' : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Receipt (Demo Attachment Required)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _receiptAttached
                        ? AppColors.success.withOpacity(0.05)
                        : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _receiptAttached
                          ? AppColors.success
                          : (_attemptedSubmit && !_receiptAttached
                              ? AppColors.error
                              : Colors.grey.shade300),
                      width: _receiptAttached ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _receiptAttached ? Icons.check_circle : Icons.receipt_long,
                        size: 40,
                        color: _receiptAttached ? AppColors.success : AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _receiptAttached ? 'Demo receipt attached' : 'No demo receipt attached',
                        style: TextStyle(
                          color: _receiptAttached ? AppColors.success : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_receiptAttached)
                        ElevatedButton.icon(
                          onPressed: _mockAttachReceipt,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Update Demo Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(200, 44),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_attemptedSubmit && !_receiptAttached)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      'A demo receipt attachment is required',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _resubmitExpense,
                  child: const Text('Resubmit Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}