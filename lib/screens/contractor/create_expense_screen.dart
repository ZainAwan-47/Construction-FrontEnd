import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';

class CreateExpenseScreen extends StatefulWidget {
  const CreateExpenseScreen({Key? key}) : super(key: key);

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
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

  void _mockAttachReceipt() {
    setState(() {
      _receiptAttached = true;
    });
  }

  void _submitExpense() {
    setState(() {
      _attemptedSubmit = true;
    });

    if (_formKey.currentState!.validate() && _receiptAttached && _selectedCategory != null) {
      final amount = parsePositivePkrAmount(_amountController.text);
      if (amount == null) return;

      final added = AppState().addExpense(
        _selectedCategory!,
        amount,
        _descriptionController.text,
        _receiptAttached,
      );
      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense was not submitted. Check the amount and active role.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mock expense submitted for review.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Returns to Dashboard
      }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWarmGray,
      appBar: AppBar(
        title: const Text('Create Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expense Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const SizedBox(height: 16),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (value) => value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                
                // Amount Field
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

                // Description Field
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
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please provide a description' : null,
                ),
                const SizedBox(height: 24),

                const Text('Receipt (Demo Attachment Required)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _receiptAttached ? AppColors.success.withOpacity(0.05) : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _receiptAttached ? AppColors.success : (_attemptedSubmit && !_receiptAttached ? AppColors.error : Colors.grey.shade300),
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
                          label: const Text('Attach Demo Receipt'),
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
                    child: Text('A demo receipt attachment is required', style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submitExpense,
                  child: const Text('Submit Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}