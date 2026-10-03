enum ExpenseStatus {
  pending,
  approved,
  disputed,
}

class Expense {
  final String id;
  String category;
  double amount;
  String description;
  bool receiptAttached;
  final DateTime date;
  ExpenseStatus status;
  List<String> feedbackHistory; // Phase 7: History array instead of single string

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.receiptAttached,
    required this.date,
    this.status = ExpenseStatus.pending,
    List<String>? feedbackHistory,
  }) : feedbackHistory = feedbackHistory ?? [];
}