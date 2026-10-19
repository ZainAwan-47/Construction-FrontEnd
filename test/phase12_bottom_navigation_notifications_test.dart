import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/models/activity_entry.dart';
import 'package:construction_management_app/models/fund_transfer.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/screens/common/activity_center_screen.dart';
import 'package:construction_management_app/screens/contractor/contractor_dashboard_screen.dart';
import 'package:construction_management_app/screens/owner/owner_dashboard_screen.dart';
import 'package:construction_management_app/state/app_state.dart';
import 'package:construction_management_app/widgets/navigation/role_bottom_nav.dart';

void main() {
  testWidgets('notification badge reacts from zero to multiple unread items', (
    tester,
  ) async {
    final state = AppState();
    state.switchRole(UserRole.owner);
    state.markAllActivitiesRead();
    state.switchRole(UserRole.contractor);
    state.markAllActivitiesRead();
    state.switchRole(UserRole.owner);
    await _pumpRoleDashboard(tester, UserRole.owner);

    var badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
    expect(find.byTooltip('Activity'), findsOneWidget);

    state.switchRole(UserRole.contractor);
    expect(
      state.addExpense('Materials', 100, 'First owner update', true),
      isTrue,
    );
    state.switchRole(UserRole.owner);
    await tester.pump();
    badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);
    expect((badge.label as Text).data, '1');
    expect(find.byTooltip('Activity, 1 unread notifications'), findsOneWidget);

    state.switchRole(UserRole.contractor);
    expect(state.addExpense('Labor', 200, 'Second owner update', true), isTrue);
    state.switchRole(UserRole.owner);
    await tester.pump();
    badge = tester.widget<Badge>(find.byType(Badge));
    expect((badge.label as Text).data, '2');
    expect(state.unreadActivityCount, 2);

    state.markAllActivitiesRead();
    await tester.pump();
    badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
    expect(state.unreadActivityCount, 0);
  });

  testWidgets(
    'milestone ready and Owner sign-off notify only the intended role once',
    (tester) async {
      final state = AppState();
      state.switchRole(UserRole.owner);
      state.markAllActivitiesRead();
      state.switchRole(UserRole.contractor);
      state.markAllActivitiesRead();

      final initialActivityCount = state.activityEntries.length;
      expect(state.markMilestoneReady(1), isTrue);
      expect(state.activityEntries, hasLength(initialActivityCount + 1));

      final readyActivity = state.activityEntries.first;
      expect(readyActivity.type, ActivityType.milestoneReady);
      expect(readyActivity.title, 'Phase 1 ready for sign-off');
      expect(readyActivity.recipientRole, UserRole.owner);
      expect(state.unreadActivityCount, 0);

      expect(state.markMilestoneReady(1), isFalse);
      state.switchRole(UserRole.owner);
      expect(state.markMilestoneReady(1), isFalse);
      expect(state.activityEntries, hasLength(initialActivityCount + 1));
      expect(state.unreadActivityCount, 1);
      expect(
        state
            .activityEntriesForRole(UserRole.contractor)
            .where((entry) => !entry.isRead),
        isEmpty,
      );

      await _pumpRoleDashboard(tester, UserRole.owner);
      var badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
      expect((badge.label as Text).data, '1');
      await tester.tap(find.byTooltip('Activity, 1 unread notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Phase 1 ready for sign-off'), findsOneWidget);

      state.switchRole(UserRole.contractor);
      await tester.pumpWidget(
        MaterialApp(
          home: const ActivityCenterScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      );
      expect(state.unreadActivityCount, 0);
      expect(find.text('Phase 1 ready for sign-off'), findsNothing);
      expect(
        state
            .activityEntriesForRole(UserRole.contractor)
            .where((entry) => !entry.isRead),
        isEmpty,
      );

      state.switchRole(UserRole.owner);
      expect(state.signOffMilestone(1), isTrue);
      expect(state.activityEntries, hasLength(initialActivityCount + 2));
      final signOffActivity = state.activityEntries.first;
      expect(signOffActivity.type, ActivityType.milestoneSignedOff);
      expect(signOffActivity.title, 'Phase 1 signed off');
      expect(signOffActivity.recipientRole, UserRole.contractor);

      expect(state.signOffMilestone(1), isFalse);
      expect(state.activityEntries, hasLength(initialActivityCount + 2));
      expect(state.unreadActivityCount, 1);
      expect(
        state
            .activityEntriesForRole(UserRole.owner)
            .where((entry) => !entry.isRead),
        hasLength(1),
      );

      state.switchRole(UserRole.contractor);
      expect(state.unreadActivityCount, 1);
      await tester.pump();
      expect(find.text('Phase 1 signed off'), findsOneWidget);
      expect(find.text('Phase 1 ready for sign-off'), findsNothing);

      state.markAllActivitiesRead();
      state.switchRole(UserRole.owner);
      state.markAllActivitiesRead();
      state.switchRole(UserRole.contractor);
    },
  );

  testWidgets(
    'transfer creation and confirmation notify the opposite role exactly once',
    (tester) async {
      final state = AppState();
      state.switchRole(UserRole.owner);
      state.markAllActivitiesRead();
      state.switchRole(UserRole.contractor);
      state.markAllActivitiesRead();
      final initialActivityCount = state.activityEntries.length;

      await _pumpRoleDashboard(tester, UserRole.contractor);
      var badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);

      expect(state.addTransfer(100, 'Wrong role', true), isFalse);
      state.switchRole(UserRole.owner);
      expect(state.addTransfer(0, 'Invalid amount', true), isFalse);
      expect(state.addTransfer(100, 'Missing proof', false), isFalse);
      expect(state.activityEntries, hasLength(initialActivityCount));

      expect(state.addTransfer(250, 'Phase 12 transfer', true), isTrue);
      expect(state.activityEntries, hasLength(initialActivityCount + 1));
      final createdActivity = state.activityEntries.first;
      expect(createdActivity.type, ActivityType.transferCreated);
      expect(createdActivity.title, 'Incoming transfer awaiting confirmation');
      expect(createdActivity.recipientRole, UserRole.contractor);
      expect(state.unreadActivityCount, 0);

      final transfer = state.pendingTransfers.last;
      expect(transfer.status, TransferStatus.awaitingConfirmation);
      expect(state.confirmTransfer(transfer.id), isFalse);
      expect(state.activityEntries, hasLength(initialActivityCount + 1));

      state.switchRole(UserRole.contractor);
      expect(state.unreadActivityCount, 1);
      await tester.pump();
      badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
      expect((badge.label as Text).data, '1');
      await tester.tap(find.byTooltip('Activity, 1 unread notifications'));
      await tester.pumpAndSettle();
      expect(
        find.text('Incoming transfer awaiting confirmation'),
        findsOneWidget,
      );
      await tester.tap(find.text('Mark as read'));
      await tester.pump();
      expect(state.unreadActivityCount, 0);

      expect(state.confirmTransfer(transfer.id), isTrue);
      expect(state.activityEntries, hasLength(initialActivityCount + 2));
      final confirmedActivity = state.activityEntries.first;
      expect(confirmedActivity.type, ActivityType.transferConfirmed);
      expect(confirmedActivity.recipientRole, UserRole.owner);
      expect(state.confirmTransfer(transfer.id), isFalse);
      expect(state.activityEntries, hasLength(initialActivityCount + 2));
      expect(state.unreadActivityCount, 0);

      state.switchRole(UserRole.owner);
      await tester.pump();
      expect(state.unreadActivityCount, 1);
      expect(find.text('Transfer confirmed'), findsOneWidget);
      expect(
        find.text('Incoming transfer awaiting confirmation'),
        findsNothing,
      );

      state.switchRole(UserRole.contractor);
      expect(state.unreadActivityCount, 0);
      expect(
        state
            .activityEntriesForRole(UserRole.contractor)
            .where((entry) => !entry.isRead),
        isEmpty,
      );

      state.switchRole(UserRole.owner);
      state.markAllActivitiesRead();
      state.switchRole(UserRole.contractor);
      state.markAllActivitiesRead();
    },
  );

  testWidgets('Owner tabs change content and preserve state and shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppState().switchRole(UserRole.owner);
    await _pumpRoleDashboard(tester, UserRole.owner);
    expect(_selectedTab(tester), 0);

    await _tapTab(tester, 'Funds');
    expect(_selectedTab(tester), 1);
    expect(find.text('Transfer Details'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '12345');

    await _tapTab(tester, 'Review');
    expect(_selectedTab(tester), 2);
    expect(find.text('Review Expenses'), findsOneWidget);
    await _tapTab(tester, 'Milestones');
    expect(_selectedTab(tester), 3);
    expect(find.text('Project Progress'), findsOneWidget);
    await _tapTab(tester, 'Settings');
    expect(_selectedTab(tester), 4);
    expect(find.text('Demo Account'), findsOneWidget);

    await _tapTab(tester, 'Funds');
    expect(_selectedTab(tester), 1);
    expect(find.text('12345'), findsOneWidget);
    final transferCountBeforeSubmit = AppState().allTransfers.length;

    await tester.tap(find.widgetWithText(ElevatedButton, 'Attach Demo Proof'));
    await tester.pumpAndSettle();
    expect(find.text('Demo proof attached'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send Funds'));
    await tester.pumpAndSettle();
    expect(AppState().allTransfers, hasLength(transferCountBeforeSubmit + 1));
    expect(AppState().activityEntries.first.type, ActivityType.transferCreated);
    expect(AppState().activityEntries.first.recipientRole, UserRole.contractor);
    expect(_selectedTab(tester), 0);
    expect(find.text('Project Overview'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);
  });

  testWidgets(
    'Owner tab Back button follows history and matches Android Back',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppState().switchRole(UserRole.owner);
      await _pumpRoleDashboard(tester, UserRole.owner);
      expect(find.byTooltip('Back'), findsNothing);

      await _tapTab(tester, 'Funds');
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Project Overview'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await _tapTab(tester, 'Funds');
      await _tapTab(tester, 'Review');
      expect(_selectedTab(tester), 2);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 1);
      expect(find.text('Transfer Details'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Project Overview'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await _tapTab(tester, 'Funds');
      await _tapTab(tester, 'Home');
      expect(_selectedTab(tester), 0);
      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 1);
      expect(find.text('Transfer Details'), findsOneWidget);
    },
  );

  testWidgets(
    'Contractor tabs persist and workflow routes return to selected tab',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppState().switchRole(UserRole.contractor);
      await _pumpRoleDashboard(tester, UserRole.contractor);
      expect(_selectedTab(tester), 0);

      await _tapTab(tester, 'Expenses');
      expect(_selectedTab(tester), 1);
      expect(find.text('My Expenses'), findsOneWidget);

      await _tapTab(tester, 'Milestones');
      expect(_selectedTab(tester), 2);
      expect(find.text('Project Progress'), findsOneWidget);
      await tester.tap(find.text('Phase 1').first);
      await tester.pumpAndSettle();
      expect(find.text('Phase 1 Details'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 2);
      expect(find.text('Project Progress'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await _tapTab(tester, 'Settings');
      expect(_selectedTab(tester), 3);
      expect(find.text('Demo Account'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 2);
      expect(find.text('Project Progress'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      await _tapTab(tester, 'Settings');
      await _tapTab(tester, 'Home');
      expect(_selectedTab(tester), 0);
      expect(find.text('Site Operations'), findsOneWidget);
    },
  );

  testWidgets(
    'Contractor tab Back button follows history and matches Android Back',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppState().switchRole(UserRole.contractor);
      await _pumpRoleDashboard(tester, UserRole.contractor);
      expect(find.byTooltip('Back'), findsNothing);

      await _tapTab(tester, 'Expenses');
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await _tapTab(tester, 'Expenses');
      await _tapTab(tester, 'Milestones');
      expect(_selectedTab(tester), 2);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 1);
      expect(find.text('My Expenses'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      expect(find.text('Project Overview'), findsNothing);

      await _tapTab(tester, 'Expenses');
      await _tapTab(tester, 'Home');
      expect(_selectedTab(tester), 0);
      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 1);
      expect(find.text('My Expenses'), findsOneWidget);
    },
  );

  testWidgets('Owner Settings Back follows history and falls back to Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppState().switchRole(UserRole.owner);
    await _pumpRoleDashboard(tester, UserRole.owner);

    await _tapTab(tester, 'Funds');
    await _tapTab(tester, 'Settings');
    expect(_selectedTab(tester), 4);
    expect(find.text('Demo Account'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 1);
    expect(find.text('Transfer Details'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);

    await _tapTab(tester, 'Settings');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 1);
    expect(find.text('Transfer Details'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 0);
    expect(find.text('Project Overview'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);

    await _tapTab(tester, 'Settings');
    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 0);
    expect(find.text('Project Overview'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);

    await _tapTab(tester, 'Settings');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 0);
    expect(find.text('Project Overview'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);
  });

  testWidgets(
    'Contractor Settings Back follows history and falls back to Home',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppState().switchRole(UserRole.contractor);
      await _pumpRoleDashboard(tester, UserRole.contractor);

      await _tapTab(tester, 'Expenses');
      await _tapTab(tester, 'Settings');
      expect(_selectedTab(tester), 3);
      expect(find.text('Demo Account'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 1);
      expect(find.text('My Expenses'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await _tapTab(tester, 'Settings');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 1);
      expect(find.text('My Expenses'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      expect(find.text('Project Overview'), findsNothing);

      await _tapTab(tester, 'Settings');
      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);

      await _tapTab(tester, 'Settings');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(find.text('Site Operations'), findsOneWidget);
      expect(find.byType(RoleBottomNav), findsOneWidget);
      expect(find.text('Project Overview'), findsNothing);
    },
  );

  testWidgets('Android Back from an Owner non-Home tab returns Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppState().switchRole(UserRole.owner);
    await _pumpRoleDashboard(tester, UserRole.owner);
    await _tapTab(tester, 'Review');
    expect(_selectedTab(tester), 2);
    expect(find.text('Review Expenses'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 0);
    expect(find.text('Project Overview'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);
    expect(find.textContaining('No route defined'), findsNothing);
  });

  testWidgets('Owner workflow detail returns to its tab by app-bar Back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppState().switchRole(UserRole.owner);
    await _pumpRoleDashboard(tester, UserRole.owner);
    await _tapTab(tester, 'Review');
    expect(_selectedTab(tester), 2);

    await tester.tap(find.text('PVC pipes and fittings').first);
    await tester.pumpAndSettle();
    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 2);
    expect(find.text('Review Expenses'), findsOneWidget);
    expect(find.byType(RoleBottomNav), findsOneWidget);
  });

  testWidgets('activity read actions and role-specific feed are reactive', (
    tester,
  ) async {
    final state = AppState();
    state.switchRole(UserRole.contractor);
    state.markAllActivitiesRead();
    expect(
      state.addExpense('Materials', 300, 'Owner notification one', true),
      isTrue,
    );
    expect(
      state.addExpense('Labor', 400, 'Owner notification two', true),
      isTrue,
    );

    state.switchRole(UserRole.owner);
    await tester.pumpWidget(
      MaterialApp(
        home: const ActivityCenterScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
    expect(state.unreadActivityCount, 2);
    expect(
      state
          .activityEntriesForRole(UserRole.owner)
          .where((entry) => !entry.isRead)
          .length,
      2,
    );
    expect(find.text('Mark all read'), findsOneWidget);
    await tester.tap(find.text('Mark as read').first);
    await tester.pump();
    expect(state.unreadActivityCount, 1);
    expect(find.text('Mark all read'), findsOneWidget);
    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    expect(state.unreadActivityCount, 0);
    expect(find.text('Mark all read'), findsNothing);

    final firstExpenseId = state.allExpenses.first.id;
    expect(state.approveExpense(firstExpenseId), isTrue);
    await tester.pump();
    expect(state.unreadActivityCount, 0);

    state.switchRole(UserRole.contractor);
    await tester.pump();
    expect(state.unreadActivityCount, 1);
    expect(find.text('Expense approved'), findsOneWidget);
    expect(find.text('Expense submitted'), findsNothing);
    final ownerNotificationId = state
        .activityEntriesForRole(UserRole.owner)
        .first
        .id;
    expect(state.markActivityRead(ownerNotificationId), isFalse);
    expect(state.markActivityRead(state.activityEntries.first.id), isTrue);
    expect(state.unreadActivityCount, 0);
  });

  test('rejected and repeated transitions do not create notifications', () {
    final state = AppState();
    state.switchRole(UserRole.owner);
    final before = state.activityEntries.length;
    expect(state.confirmTransfer('missing-transfer'), isFalse);
    expect(state.signOffMilestone(1), isFalse);
    expect(state.recordFinalInspection(approved: true, feedback: ''), isFalse);
    expect(state.completeProject(), isFalse);
    expect(state.activityEntries, hasLength(before));
  });
}

Future<void> _pumpRoleDashboard(WidgetTester tester, UserRole role) async {
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

int _selectedTab(WidgetTester tester) => tester
    .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
    .currentIndex;

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
