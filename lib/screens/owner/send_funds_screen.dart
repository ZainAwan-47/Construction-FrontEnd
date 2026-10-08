import 'package:flutter/material.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';

class SendFundsScreen extends StatefulWidget {
  const SendFundsScreen({Key? key}) : super(key: key);

  @override
  State<SendFundsScreen> createState() => _SendFundsScreenState();
}

class _SendFundsScreenState extends State<SendFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _proofAttached = false;
  bool _attemptedSubmit = false;

  void _mockAttachProof() {
    setState(() {
      _proofAttached = true;
    });
  }

  void _submitTransfer() {
    setState(() {
      _attemptedSubmit = true;
    });

    if (_formKey.currentState!.validate() && _proofAttached) {
      final amount = parsePositivePkrAmount(_amountController.text);
      if (amount == null) return;

      final added = AppState().addTransfer(
        amount,
        _referenceController.text.isEmpty ? 'Fund Transfer' : _referenceController.text,
        _proofAttached,
      );
      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer was not recorded. Check the amount and active role.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mock transfer recorded. Awaiting contractor confirmation.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
      }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWarmGray,
      appBar: AppBar(
        title: const Text('Send Funds'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Transfer Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
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
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: 'Reference / Note (Optional)',
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Payment Proof (Demo Attachment Required)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _proofAttached ? AppColors.success.withOpacity(0.05) : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _proofAttached ? AppColors.success : (_attemptedSubmit && !_proofAttached ? AppColors.error : Colors.grey.shade300),
                      width: _proofAttached ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _proofAttached ? Icons.check_circle : Icons.upload_file,
                        size: 40,
                        color: _proofAttached ? AppColors.success : AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _proofAttached ? 'Demo proof attached' : 'No demo proof attached',
                        style: TextStyle(
                          color: _proofAttached ? AppColors.success : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_proofAttached)
                        ElevatedButton.icon(
                          onPressed: _mockAttachProof,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Attach Demo Proof'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(200, 44),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_attemptedSubmit && !_proofAttached)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text('A demo proof attachment is required', style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submitTransfer,
                  child: const Text('Send Funds'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}