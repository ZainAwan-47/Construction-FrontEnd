double? parsePositivePkrAmount(String? input) {
  if (input == null) return null;

  final value = input.trim();
  final validAmount = RegExp(r'^(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$');
  if (!validAmount.hasMatch(value)) return null;

  final amount = double.tryParse(value.replaceAll(',', ''));
  if (amount == null || !amount.isFinite || amount <= 0) return null;
  return amount;
}

String formatPkrCurrency(double amount) {
  if (!amount.isFinite) return 'PKR --';

  final parts = amount.toStringAsFixed(2).split('.');
  final groupedWholeAmount = parts.first.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return 'PKR $groupedWholeAmount.${parts.last}';
}