import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/models/activity_entry.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/screens/common/activity_center_screen.dart';
import 'package:construction_management_app/screens/common/settings_screen.dart';
import 'package:construction_management_app/screens/contractor/contractor_dashboard_screen.dart';
import 'package:construction_management_app/screens/owner/owner_dashboard_screen.dart';
import 'package:construction_management_app/state/app_state.dart';
import 'package:construction_management_app/widgets/navigation/role_bottom_nav.dart';

void main() {
  testWidgets('both dashboards open the shared empty Activity Center', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    state.switchRole(UserRole.owner);
    await _pumpDashboard(tester, UserRole.owner);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Funds'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.byTooltip('Activity'), findsOneWidget);
    await tester.tap(find.byTooltip('Activity'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCenterScreen), findsOneWidget);
    expect(find.text('You’re all caught up'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    state.switchRole(UserRole.contractor);
    await _pumpDashboard(tester, UserRole.contractor);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.byTooltip('Activity'), findsOneWidget);
    expect(find.text('My Expenses'), findsNothing);
    expect(find.byType(RoleBottomNav), findsOneWidget);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .items
          .map((item) => item.label),
      ['Home', 'Expenses', 'Milestones', 'Settings'],
    );
    await tester.tap(find.byTooltip('Activity'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCenterScreen), findsOneWidget);
  });

  testWidgets('role-specific bottom tabs guard invalid indices and selection', (
    tester,
  ) async {
    final forwardedIndices = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: RoleBottomNav(
            role: UserRole.owner,
            currentIndex: 99,
            onTap: forwardedIndices.add,
          ),
        ),
      ),
    );

    var nav = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(nav.currentIndex, 0);
    expect(nav.items.map((item) => item.label), [
      'Home',
      'Funds',
      'Review',
      'Milestones',
      'Settings',
    ]);
    nav.onTap!(-1);
    nav.onTap!(nav.items.length);
    expect(forwardedIndices, isEmpty);
    nav.onTap!(2);
    expect(forwardedIndices, [2]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: RoleBottomNav(
            role: UserRole.contractor,
            currentIndex: 3,
            onTap: forwardedIndices.add,
          ),
        ),
      ),
    );
    nav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(nav.currentIndex, 3);
    expect(nav.items.map((item) => item.label), [
      'Home',
      'Expenses',
      'Milestones',
      'Settings',
    ]);
  });

  testWidgets('Settings validates and saves the local demo profile', (
    tester,
  ) async {
    final state = AppState();
    state.switchRole(UserRole.owner);
    await tester.pumpWidget(
      MaterialApp(
        home: const SettingsScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );

    expect(find.text('Demo Account'), findsOneWidget);
    expect(
      find.text(
        'Stored locally for this app session only. No account service is connected.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a display name.'), findsOneWidget);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(state.demoProfileName, 'Demo User');

    await tester.enterText(find.byType(TextFormField).at(0), 'Alex Owner');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'alex@example.com',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(state.demoProfileName, 'Alex Owner');
    expect(state.demoProfileEmail, 'alex@example.com');
    expect(find.text('Alex Owner'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Unsaved name');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(state.demoProfileName, 'Alex Owner');
    expect(find.text('Alex Owner'), findsOneWidget);
  });

  testWidgets(
    'Settings role switching replaces the stack with the chosen dashboard',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = AppState();
      state.switchRole(UserRole.owner);
      await tester.pumpWidget(
        MaterialApp(
          home: const OwnerDashboardScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(find.text('Current Mode: Owner'), findsOneWidget);

      await tester.tap(find.text('Contractor').first);
      await tester.pumpAndSettle();
      expect(state.activeRole, UserRole.contractor);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(find.text('Current Mode: Contractor'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Active Workspace Role'), findsNothing);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.textContaining('No route defined'), findsNothing);
    },
  );

  testWidgets(
    'demo sign-out requires confirmation and clears dashboard history',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppState().switchRole(UserRole.contractor);
      await tester.pumpWidget(
        MaterialApp(
          home: const ContractorDashboardScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Out of Demo'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out of the demo?'), findsOneWidget);
      expect(find.text('Site Operations'), findsNothing);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Active Workspace Role'), findsOneWidget);

      await tester.tap(find.text('Sign Out of Demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Out').last);
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Site Operations'), findsNothing);
    },
  );

  testWidgets('Activity Center updates on successful state changes only', (
    tester,
  ) async {
    final state = AppState();
    state.switchRole(UserRole.contractor);
    await tester.pumpWidget(const MaterialApp(home: ActivityCenterScreen()));
    expect(find.text('You’re all caught up'), findsOneWidget);

    final before = state.activityEntries.length;
    expect(state.addExpense('Materials', 0, 'Invalid activity', true), isFalse);
    expect(state.activityEntries, hasLength(before));
    expect(
      state.addExpense('Materials', 1250, 'Activity feed sample', true),
      isTrue,
    );
    await tester.pump();
    expect(state.activityEntries.first.type, ActivityType.expenseSubmitted);
    expect(() => state.activityEntries.clear(), throwsUnsupportedError);

    state.switchRole(UserRole.owner);
    await tester.pump();
    expect(find.text('Expense submitted'), findsOneWidget);
    expect(
      find.text('A Materials expense is awaiting owner review.'),
      findsOneWidget,
    );
    expect(find.text('You’re all caught up'), findsNothing);
  });

  test('successful workflow transitions create ordered activities once', () {
    final state = AppState();
    final initialCount = state.activityEntries.length;

    state.switchRole(UserRole.owner);
    expect(state.approveExpense('unknown'), isFalse);
    expect(state.recordFinalInspection(approved: true, feedback: ''), isFalse);
    expect(state.activityEntries, hasLength(initialCount));

    expect(state.disputeExpense('exp_003', 'Please revise this item.'), isTrue);
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);
    final disputedCount = state.activityEntries.length;
    expect(state.disputeExpense('exp_003', 'Repeated action'), isFalse);
    expect(state.activityEntries, hasLength(disputedCount));

    state.switchRole(UserRole.contractor);
    expect(
      state.resubmitExpense(
        'exp_003',
        'Plumbing',
        44000,
        'Revised pipe estimate',
        true,
      ),
      isTrue,
    );
    expect(state.activityEntries.first.recipientRole, UserRole.owner);
    final resubmittedCount = state.activityEntries.length;
    expect(
      state.resubmitExpense(
        'exp_003',
        'Plumbing',
        44000,
        'Repeated revision',
        true,
      ),
      isFalse,
    );
    expect(state.activityEntries, hasLength(resubmittedCount));

    expect(
      state.addExpense('Tile', 900, 'Phase 11 test expense', true),
      isTrue,
    );
    expect(state.activityEntries.first.recipientRole, UserRole.owner);
    final newExpenseId = state.allExpenses.first.id;
    state.switchRole(UserRole.owner);
    expect(state.approveExpense(newExpenseId), isTrue);
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);
    final approvedCount = state.activityEntries.length;
    expect(state.approveExpense(newExpenseId), isFalse);
    expect(state.activityEntries, hasLength(approvedCount));

    expect(state.addTransfer(100, 'Demo activity transfer', true), isTrue);
    expect(state.activityEntries.first.type, ActivityType.transferCreated);
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);
    final transferId = state.pendingTransfers.last.id;
    state.switchRole(UserRole.contractor);
    expect(state.confirmTransfer(transferId), isTrue);
    expect(state.activityEntries.first.type, ActivityType.transferConfirmed);
    expect(state.activityEntries.first.recipientRole, UserRole.owner);
    final confirmedCount = state.activityEntries.length;
    expect(state.confirmTransfer(transferId), isFalse);
    expect(state.activityEntries, hasLength(confirmedCount));

    expect(state.markMilestoneReady(1), isTrue);
    expect(state.activityEntries.first.type, ActivityType.milestoneReady);
    expect(state.activityEntries.first.recipientRole, UserRole.owner);
    state.switchRole(UserRole.owner);
    expect(state.signOffMilestone(1), isTrue);
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);
    final signOffCount = state.activityEntries.length;
    expect(state.signOffMilestone(1), isFalse);
    expect(state.activityEntries, hasLength(signOffCount));
    expect(
      state.recordFinalInspection(
        approved: false,
        feedback: 'Inspect remaining work.',
      ),
      isTrue,
    );
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);

    state.switchRole(UserRole.contractor);
    expect(
      state.resubmitExpense(
        'exp_002',
        'Equipment',
        149000,
        'Revised generator estimate',
        true,
      ),
      isTrue,
    );
    state.switchRole(UserRole.owner);
    expect(state.approveExpense('exp_002'), isTrue);

    for (var id = 2; id <= 6; id++) {
      state.switchRole(UserRole.contractor);
      expect(state.markMilestoneReady(id), isTrue);
      state.switchRole(UserRole.owner);
      expect(state.signOffMilestone(id), isTrue);
    }
    expect(state.approveExpense('exp_003'), isTrue);
    final activityTestExpense = state.allExpenses.firstWhere(
      (expense) => expense.description == 'Activity feed sample',
    );
    expect(state.approveExpense(activityTestExpense.id), isTrue);
    expect(state.recordFinalInspection(approved: true, feedback: ''), isTrue);
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);
    expect(state.completeProject(), isTrue);
    expect(state.activityEntries.first.recipientRole, UserRole.contractor);
    final completedCount = state.activityEntries.length;
    expect(state.completeProject(), isFalse);
    expect(state.activityEntries, hasLength(completedCount));

    expect(
      state.activityEntries.map((entry) => entry.type),
      containsAll([
        ActivityType.expenseSubmitted,
        ActivityType.expenseApproved,
        ActivityType.expenseDisputed,
        ActivityType.expenseResubmitted,
        ActivityType.transferCreated,
        ActivityType.transferConfirmed,
        ActivityType.milestoneSignedOff,
        ActivityType.inspectionRecorded,
        ActivityType.projectCompleted,
      ]),
    );
    expect(state.activityEntries.first.type, ActivityType.projectCompleted);
    expect(state.activityEntries.last.type, ActivityType.expenseSubmitted);
    expect(
      state.activityEntries.every(
        (entry) => !entry.description.contains('PKR'),
      ),
      isTrue,
    );
  });
}

Future<void> _pumpDashboard(WidgetTester tester, UserRole role) async {
  await tester.pumpWidget(
    MaterialApp(
      home: role == UserRole.owner
          ? const OwnerDashboardScreen()
          : const ContractorDashboardScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    ),
  );
  await tester.pumpAndSettle();
}
