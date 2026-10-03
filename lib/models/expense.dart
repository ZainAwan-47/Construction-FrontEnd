enum ExpenseStatus {
  pending,
  approved,
  disputed,
}

class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final bool receiptAttached;
  final DateTime date;
  ExpenseStatus status;
  String? feedback; // Added for Phase 6 Dispute workflow

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.receiptAttached,
    required this.date,
    this.status = ExpenseStatus.pending,
    this.feedback,
  });
}