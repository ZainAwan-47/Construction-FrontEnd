import 'package:flutter/material.dart';
import '../models/user_role.dart';

class AppState extends ChangeNotifier {
  // Singleton pattern for native, dependency-free state access
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Navigation & Role State
  UserRole _activeRole = UserRole.owner;
  UserRole get activeRole => _activeRole;

  void switchRole(UserRole newRole) {
    _activeRole = newRole;
    notifyListeners();
  }

  // --- MOCK FINANCIAL DATA (Phase 3 Foundation) ---
  final double _totalProjectBudget = 5000000.0; 
  final double _totalConfirmedInflow = 3500000.0; 
  final double _totalApprovedExpenses = 2300000.0; 
  
  final double _unconfirmedIncomingFunds = 500000.0; 
  final double _totalDisputedExpenses = 150000.0; 
  final int _pendingReviewCount = 3;

  // --- CORE BUSINESS LOGIC FORMULAS ---
  double get totalProjectBudget => _totalProjectBudget;
  double get totalApprovedExpenses => _totalApprovedExpenses;
  double get unconfirmedIncomingFunds => _unconfirmedIncomingFunds;
  double get totalDisputedExpenses => _totalDisputedExpenses;
  int get pendingReviewCount => _pendingReviewCount;

  double get remainingProjectBudget => _totalProjectBudget - _totalApprovedExpenses;
  double get contractorCashInHand => _totalConfirmedInflow - _totalApprovedExpenses;
}