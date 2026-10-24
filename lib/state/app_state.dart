import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/fund_transfer.dart';
import '../models/expense.dart';
import '../models/final_inspection.dart';
import '../models/milestone.dart';
import '../models/activity_entry.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  UserRole _activeRole = UserRole.owner;
  UserRole get activeRole => _activeRole;

  String _demoProfileName = 'Demo User';
  String get demoProfileName => _demoProfileName;

  String _demoProfileEmail = 'ahmad@email.com';
  String get demoProfileEmail => _demoProfileEmail;

  bool updateDemoProfile({required String name, required String email}) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    if (trimmedName.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmedEmail)) {
      return false;
    }

    _demoProfileName = trimmedName;
    _demoProfileEmail = trimmedEmail;
    notifyListeners();
    return true;
  }

  final List<ActivityEntry> _activityEntries = [];
  int _nextActivityId = 0;
  List<ActivityEntry> get activityEntries =>
      List.unmodifiable(_activityEntries);

  List<ActivityEntry> activityEntriesForRole(UserRole role) =>
      List.unmodifiable(
        _activityEntries.where(
          (entry) =>
              entry.recipientRole ==
              (role == UserRole.both ? UserRole.owner : role),
        ),
      );

  UserRole get _activeActivityRole =>
      _activeRole == UserRole.both ? UserRole.owner : _activeRole;

  int get unreadActivityCount => _activityEntries
      .where(
        (entry) => entry.recipientRole == _activeActivityRole && !entry.isRead,
      )
      .length;

  bool markActivityRead(int id) {
    final index = _activityEntries.indexWhere(
      (entry) =>
          entry.id == id &&
          entry.recipientRole == _activeActivityRole &&
          !entry.isRead,
    );
    if (index == -1) return false;
    _activityEntries[index].isRead = true;
    notifyListeners();
    return true;
  }

  void markAllActivitiesRead() {
    var changed = false;
    for (final entry in _activityEntries) {
      if (entry.recipientRole == _activeActivityRole && !entry.isRead) {
        entry.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void _recordActivity(
    ActivityType type,
    String title,
    String description, {
    required UserRole recipientRole,
  }) {
    _activityEntries.insert(
      0,
      ActivityEntry(
        id: ++_nextActivityId,
        type: type,
        title: title,
        description: description,
        occurredAt: DateTime.now(),
        recipientRole: recipientRole,
      ),
    );
  }

  void switchRole(UserRole newRole) {
    if (_activeRole == newRole) return;
    _activeRole = newRole;
    notifyListeners();
  }

  final double _totalProjectBudget = 5000000.0;

  // --- PHASE 8: MILESTONE STATE ---
  final List<Milestone> _milestones = [
    Milestone(
      id: 1,
      title: 'Site Prep & Layout',
      description:
          'Machinery rentals, gravel, termite spray. Plot layout, boundary work, trenching, soil test.',
      status: MilestoneStatus.inProgress,
    ),
    Milestone(
      id: 2,
      title: 'Foundation & Base',
      description:
          'Grade-60 Steel, concrete, stone ballast. Footings cast, plinth beam concrete cured.',
      status: MilestoneStatus.locked,
    ),
    Milestone(
      id: 3,
      title: 'Superstructure',
      description:
          'Bricks, cement, sand, scaffolding. Columns raised, brick walls, roof slab cast.',
      status: MilestoneStatus.locked,
    ),
    Milestone(
      id: 4,
      title: 'MEP Rough-Ins',
      description:
          'PVC pipes, conduit, copper cables. Concealed plumbing/wiring pressure-tested.',
      status: MilestoneStatus.locked,
    ),
    Milestone(
      id: 5,
      title: 'Plaster & Flooring',
      description:
          'Plaster sand, tiles, marble, chemical. Screed, plaster curing, tile fixing.',
      status: MilestoneStatus.locked,
    ),
    Milestone(
      id: 6,
      title: 'Finishing & Handover',
      description:
          'Paint, primer, fixtures, woodwork. Final paint coats, fixtures, deep cleaning.',
      status: MilestoneStatus.locked,
    ),
  ];

  List<Milestone> get allMilestones => List.unmodifiable(_milestones);
  int get completedMilestoneCount =>
      _milestones.where((m) => m.status == MilestoneStatus.completed).length;
  List<String> get handoverBlockers {
    final blockers = <String>[
      for (final milestone in _milestones)
        if (milestone.status != MilestoneStatus.completed)
          'Phase ${milestone.id}: ${milestone.title} is ${_milestoneStatusLabel(milestone.status)}',
      for (final expense in _expenses)
        if (expense.status != ExpenseStatus.approved)
          'Expense: ${expense.description} is ${_expenseStatusLabel(expense.status)}',
      for (final transfer in _transfers)
        if (transfer.status != TransferStatus.confirmed)
          'Transfer: ${transfer.reference} is awaiting confirmation',
    ];
    return List.unmodifiable(blockers);
  }

  List<FinalInspectionRecord> get finalInspectionRecords =>
      List.unmodifiable(_finalInspectionRecords);

  FinalInspectionRecord? get latestFinalInspection =>
      _finalInspectionRecords.isEmpty ? null : _finalInspectionRecords.last;

  DateTime? get projectCompletedDate => _projectCompletedDate;
  bool get isProjectCompleted => _projectCompletedDate != null;
  bool get isReadyForHandover => handoverBlockers.isEmpty;

  String _milestoneStatusLabel(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.locked:
        return 'locked';
      case MilestoneStatus.inProgress:
        return 'in progress';
      case MilestoneStatus.awaitingSignOff:
        return 'awaiting owner sign-off';
      case MilestoneStatus.completed:
        return 'completed';
    }
  }

  String _expenseStatusLabel(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return 'pending review';
      case ExpenseStatus.approved:
        return 'approved';
      case ExpenseStatus.disputed:
        return 'disputed';
    }
  }

  final List<FinalInspectionRecord> _finalInspectionRecords = [];
  DateTime? _projectCompletedDate;

  bool recordFinalInspection({
    required bool approved,
    required String feedback,
  }) {
    if (_activeRole == UserRole.contractor || isProjectCompleted) return false;
    if (!approved && feedback.trim().isEmpty) return false;
    if (approved && !isReadyForHandover) return false;
    if (approved && latestFinalInspection?.approved == true) return false;

    _finalInspectionRecords.add(
      FinalInspectionRecord(
        approved: approved,
        feedback: feedback.trim(),
        date: DateTime.now(),
      ),
    );
    _recordActivity(
      ActivityType.inspectionRecorded,
      approved ? 'Final inspection approved' : 'Inspection needs work',
      approved
          ? 'The owner recorded approval after all handover requirements were met.'
          : 'The owner recorded inspection feedback for the contractor.',
      recipientRole: UserRole.contractor,
    );
    notifyListeners();
    return true;
  }

  bool completeProject() {
    if (_activeRole == UserRole.contractor ||
        isProjectCompleted ||
        !isReadyForHandover ||
        latestFinalInspection?.approved != true) {
      return false;
    }

    _projectCompletedDate = DateTime.now();
    _recordActivity(
      ActivityType.projectCompleted,
      'Project handover recorded',
      'The owner marked the project complete in this local demo.',
      recipientRole: UserRole.contractor,
    );
    notifyListeners();
    return true;
  }

  bool markMilestoneReady(int id) {
    // Role check: Contractor only
    if (_activeRole == UserRole.owner) return false;

    final index = _milestones.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final target = _milestones[index];
    if (target.status != MilestoneStatus.inProgress) return false;

    target.status = MilestoneStatus.awaitingSignOff;
    _recordActivity(
      ActivityType.milestoneReady,
      'Phase $id ready for sign-off',
      'The contractor marked ${target.title} ready for Owner sign-off.',
      recipientRole: UserRole.owner,
    );
    notifyListeners();
    return true;
  }

  bool signOffMilestone(int id) {
    // Role check: Owner only
    if (_activeRole == UserRole.contractor) return false;

    final index = _milestones.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final target = _milestones[index];
    // Enforce: Owner sign-off permitted ONLY when awaitingSignOff
    if (target.status != MilestoneStatus.awaitingSignOff) return false;

    // Sequential enforcement
    if (id > 1) {
      final prevIndex = _milestones.indexWhere((m) => m.id == id - 1);
      if (prevIndex == -1 ||
          _milestones[prevIndex].status != MilestoneStatus.completed) {
        return false;
      }
    }

    target.status = MilestoneStatus.completed;
    target.completedDate = DateTime.now();

    // Unlock next milestone sequentially
    if (id < 6) {
      final nextIndex = _milestones.indexWhere((m) => m.id == id + 1);
      if (nextIndex != -1 &&
          _milestones[nextIndex].status == MilestoneStatus.locked) {
        _milestones[nextIndex].status = MilestoneStatus.inProgress;
      }
    }
    _recordActivity(
      ActivityType.milestoneSignedOff,
      'Phase $id signed off',
      'The owner completed ${target.title}.',
      recipientRole: UserRole.contractor,
    );
    notifyListeners();
    return true;
  }

  // --- PHASE 5, 6, 7: EXPENSE STATE ---
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
      feedbackHistory: [
        'Price too high. Please provide market rate comparison.',
      ],
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
  List<Expense> get approvedExpenses => List.unmodifiable(
    _expenses.where((e) => e.status == ExpenseStatus.approved),
  );

  double get totalApprovedExpenses => _expenses
      .where((e) => e.status == ExpenseStatus.approved)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalPendingExpenses => _expenses
      .where((e) => e.status == ExpenseStatus.pending)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalDisputedExpenses => _expenses
      .where((e) => e.status == ExpenseStatus.disputed)
      .fold(0.0, (sum, e) => sum + e.amount);

  int get pendingReviewCount =>
      _expenses.where((e) => e.status == ExpenseStatus.pending).length;

  bool addExpense(
    String category,
    double amount,
    String description,
    bool receiptAttached,
  ) {
    // Role check: Contractor only
    if (_activeRole == UserRole.owner || isProjectCompleted) return false;
    if (!amount.isFinite ||
        amount <= 0 ||
        !receiptAttached ||
        category.trim().isEmpty) {
      return false;
    }

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
    _recordActivity(
      ActivityType.expenseSubmitted,
      'Expense submitted',
      'A $category expense is awaiting owner review.',
      recipientRole: UserRole.owner,
    );
    notifyListeners();
    return true;
  }

  bool approveExpense(String id) {
    // Role check: Owner only
    if (_activeRole == UserRole.contractor || isProjectCompleted) return false;

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final expense = _expenses[index];
    if (expense.status != ExpenseStatus.pending) return false;

    expense.status = ExpenseStatus.approved;
    _recordActivity(
      ActivityType.expenseApproved,
      'Expense approved',
      'The owner approved a ${expense.category.toLowerCase()} expense.',
      recipientRole: UserRole.contractor,
    );
    notifyListeners();
    return true;
  }

  bool disputeExpense(String id, String feedback) {
    // Role check: Owner only
    if (_activeRole == UserRole.contractor || isProjectCompleted) return false;
    if (feedback.trim().isEmpty) return false;

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final expense = _expenses[index];
    if (expense.status != ExpenseStatus.pending) return false;

    expense.status = ExpenseStatus.disputed;
    expense.feedbackHistory.add(feedback.trim());
    _recordActivity(
      ActivityType.expenseDisputed,
      'Expense disputed',
      'The owner requested changes to a ${expense.category.toLowerCase()} expense.',
      recipientRole: UserRole.contractor,
    );
    notifyListeners();
    return true;
  }

  bool resubmitExpense(
    String id,
    String category,
    double amount,
    String description,
    bool receiptAttached,
  ) {
    // Role check: Contractor only
    if (_activeRole == UserRole.owner || isProjectCompleted) return false;
    if (!amount.isFinite ||
        amount <= 0 ||
        !receiptAttached ||
        category.trim().isEmpty) {
      return false;
    }

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final expense = _expenses[index];
    // Enforce: Only Disputed expenses can be adjusted and resubmitted
    if (expense.status != ExpenseStatus.disputed) return false;

    expense.category = category;
    expense.amount = amount;
    expense.description = description;
    expense.receiptAttached = receiptAttached;
    expense.status = ExpenseStatus.pending;
    _recordActivity(
      ActivityType.expenseResubmitted,
      'Expense resubmitted',
      'A revised ${expense.category.toLowerCase()} expense is awaiting owner review.',
      recipientRole: UserRole.owner,
    );
    notifyListeners();
    return true;
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

  List<FundTransfer> get pendingTransfers => _transfers
      .where((t) => t.status == TransferStatus.awaitingConfirmation)
      .toList();
  List<FundTransfer> get allTransfers => List.unmodifiable(_transfers);
  List<FundTransfer> get confirmedTransfers => List.unmodifiable(
    _transfers.where((t) => t.status == TransferStatus.confirmed),
  );

  double get _totalConfirmedInflow => _transfers
      .where((t) => t.status == TransferStatus.confirmed)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get unconfirmedIncomingFunds => _transfers
      .where((t) => t.status == TransferStatus.awaitingConfirmation)
      .fold(0.0, (sum, t) => sum + t.amount);
  double get totalConfirmedTransfers => _totalConfirmedInflow;

  bool addTransfer(double amount, String reference, bool proofAttached) {
    // Role check: Owner only
    if (_activeRole == UserRole.contractor || isProjectCompleted) return false;
    if (!amount.isFinite || amount <= 0 || !proofAttached) return false;

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
    _recordActivity(
      ActivityType.transferCreated,
      'Incoming transfer awaiting confirmation',
      'The owner recorded a demo transfer for contractor confirmation.',
      recipientRole: UserRole.contractor,
    );
    notifyListeners();
    return true;
  }

  bool confirmTransfer(String id) {
    // Role check: Contractor only
    if (_activeRole == UserRole.owner || isProjectCompleted) return false;

    final index = _transfers.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    final transfer = _transfers[index];
    // Enforce: Only transfers awaiting confirmation can be confirmed
    if (transfer.status != TransferStatus.awaitingConfirmation) return false;

    transfer.status = TransferStatus.confirmed;
    _recordActivity(
      ActivityType.transferConfirmed,
      'Transfer confirmed',
      'The contractor marked an incoming demo transfer as received.',
      recipientRole: UserRole.owner,
    );
    notifyListeners();
    return true;
  }

  // --- CORE BUSINESS LOGIC FORMULAS ---
  double get totalProjectBudget => _totalProjectBudget;
  double get remainingProjectBudget =>
      _totalProjectBudget - totalApprovedExpenses;
  double get contractorCashInHand =>
      totalConfirmedTransfers - totalApprovedExpenses;
}
