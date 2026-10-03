import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/fund_transfer.dart';

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
  final double _totalApprovedExpenses = 2300000.0; 
  final double _totalDisputedExpenses = 150000.0; 
  final int _pendingReviewCount = 3;

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
    FundTransfer(
      id: 'tx_002',
      amount: 500000.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      reference: 'Material Top-up',
      proofAttached: true,
      status: TransferStatus.awaitingConfirmation,
    ),
  ];

  List<FundTransfer> get pendingTransfers => 
      _transfers.where((t) => t.status == TransferStatus.awaitingConfirmation).toList();

  // Dynamic calculations based on transfer state
  double get _totalConfirmedInflow => _transfers
      .where((t) => t.status == TransferStatus.confirmed)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get unconfirmedIncomingFunds => _transfers
      .where((t) => t.status == TransferStatus.awaitingConfirmation)
      .fold(0.0, (sum, t) => sum + t.amount);

  // --- PHASE 4: WORKFLOW ACTIONS ---
  void addTransfer(double amount, String reference, bool proofAttached) {
    _transfers.add(
      FundTransfer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        date: DateTime.now(),
        reference: reference,
        proofAttached: proofAttached,
        status: TransferStatus.awaitingConfirmation, // Always starts unconfirmed
      ),
    );
    notifyListeners();
  }

  void confirmTransfer(String id) {
    final transfer = _transfers.firstWhere((t) => t.id == id);
    transfer.status = TransferStatus.confirmed;
    notifyListeners();
  }

  // --- CORE BUSINESS LOGIC FORMULAS (Unchanged) ---
  double get totalProjectBudget => _totalProjectBudget;
  double get totalApprovedExpenses => _totalApprovedExpenses;
  double get totalDisputedExpenses => _totalDisputedExpenses;
  int get pendingReviewCount => _pendingReviewCount;

  double get remainingProjectBudget => _totalProjectBudget - _totalApprovedExpenses;
  double get contractorCashInHand => _totalConfirmedInflow - _totalApprovedExpenses;
}