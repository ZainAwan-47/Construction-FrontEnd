import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/fund_transfer.dart';
import '../models/expense.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  UserRole _activeRole = UserRole.owner;
  UserRole get activeRole => _activeRole;

  void switchRole(UserRole newRole) {
    _activeRole = newRole;
    notifyListeners();
  }

  // --- MOCK FINANCIAL DATA (Phase 3 Foundation) ---
  final double _totalProjectBudget = 5000000.0;

  // --- PHASE 5 & 6: EXPENSE STATE ---
  final List<Expense> _expenses = [
    Expense(
      id: 'exp_001',
      category: 'Materials',
      amount: 2300000.0,
      description: 'Initial structural materials',
      receiptAttached: true,
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: ExpenseStatus.approved,
    ),
    Expense(
      id: 'exp_002',
      category: 'Equipment',
      amount: 150000.0,
      description: 'Generator rental',
      receiptAttached: true,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: ExpenseStatus.disputed,
      feedback: 'Price too high. Please provide market rate comparison.',
    ),
    Expense(
      id: 'exp_003',
      category: 'Plumbing',
      amount: 45000.0,
      description: 'PVC pipes and fittings',
      receiptAttached: true,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: ExpenseStatus.pending,
    ),
  ];

  List<Expense> get allExpenses => List.unmodifiable(_expenses);

  // Dynamic Expense Calculations
  double get totalApprovedExpenses => _expenses
      .where((e) => e.status == ExpenseStatus.approved)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalDisputedExpenses => _expenses
      .where((e) => e.status == ExpenseStatus.disputed)
      .fold(0.0, (sum, e) => sum + e.amount);

  int get pendingReviewCount => _expenses
      .where((e) => e.status == ExpenseStatus.pending)
      .length;

  void addExpense(String category, double amount, String description, bool receiptAttached) {
    _expenses.insert(
      0, 
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        amount: amount,
        description: description,
        receiptAttached: receiptAttached,
        date: DateTime.now(),
        status: ExpenseStatus.pending, 
      ),
    );
    notifyListeners();
  }

  // --- PHASE 6: OWNER REVIEW ACTIONS (Strictly Enforced) ---
  void approveExpense(String id) {
    final expense = _expenses.firstWhere((e) => e.id == id);
    
    // ENFORCEMENT: Reject invalid state transitions. 
    // An expense MUST be pending to be approved.
    if (expense.status != ExpenseStatus.pending) {
      return; 
    }
    
    expense.status = ExpenseStatus.approved;
    notifyListeners();
  }

  void disputeExpense(String id, String feedback) {
    final expense = _expenses.firstWhere((e) => e.id == id);
    
    // ENFORCEMENT: Reject invalid state transitions.
    // An expense MUST be pending to be disputed.
    if (expense.status != ExpenseStatus.pending) {
      return; 
    }
    
    expense.status = ExpenseStatus.disputed;
    expense.feedback = feedback;
    notifyListeners();
  }

  // --- PHASE 4: FUNDS TRANSFER STATE ---
  final List<FundTransfer> _transfers = [
    FundTransfer(
      id: 'tx_001',
      amount: 3500000.0,
      date: DateTime.now().subtract(const Duration(days: 10)),
      reference: 'Initial Advance',
      proofAttached: true,
      status: TransferStatus.confirmed,
    ),
  ];

  List<FundTransfer> get pendingTransfers =>
      _transfers.where((t) => t.status == TransferStatus.awaitingConfirmation).toList();

  double get _totalConfirmedInflow => _transfers
      .where((t) => t.status == TransferStatus.confirmed)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get unconfirmedIncomingFunds => _transfers
      .where((t) => t.status == TransferStatus.awaitingConfirmation)
      .fold(0.0, (sum, t) => sum + t.amount);

  void addTransfer(double amount, String reference, bool proofAttached) {
    _transfers.add(
      FundTransfer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        date: DateTime.now(),
        reference: reference,
        proofAttached: proofAttached,
        status: TransferStatus.awaitingConfirmation,
      ),
    );
    notifyListeners();
  }

  void confirmTransfer(String id) {
    final transfer = _transfers.firstWhere((t) => t.id == id);
    transfer.status = TransferStatus.confirmed;
    notifyListeners();
  }

  // --- CORE BUSINESS LOGIC FORMULAS ---
  double get totalProjectBudget => _totalProjectBudget;
  double get remainingProjectBudget => _totalProjectBudget - totalApprovedExpenses;
  double get contractorCashInHand => _totalConfirmedInflow - totalApprovedExpenses;
}