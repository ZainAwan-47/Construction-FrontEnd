import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/models/milestone.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/screens/contractor/contractor_dashboard_screen.dart';
import 'package:construction_management_app/screens/common/final_inspection_screen.dart';
import 'package:construction_management_app/screens/common/final_project_report_screen.dart';
import 'package:construction_management_app/screens/owner/owner_dashboard_screen.dart';
import 'package:construction_management_app/state/app_state.dart';

void main() {
  const printingChannel = MethodChannel('net.nfet.printing');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, null);
  });

  testWidgets(
    'contractor can review readiness and report but not approve handover',
    (tester) async {
      final state = AppState();
      state.switchRole(UserRole.contractor);

      await tester.pumpWidget(const MaterialApp(home: FinalInspectionScreen()));
      expect(find.text('Project Readiness'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Outstanding Items'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.scrollUntilVisible(
        find.textContaining('Generator rental'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Generator rental'), findsOneWidget);
      expect(find.text('Approve Final Inspection'), findsNothing);
      expect(find.text('Confirm Project Handover'), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(home: FinalProjectReportScreen()),
      );
      expect(find.text('Final Project Report'), findsOneWidget);
      expect(find.text('Financial Summary'), findsOneWidget);
      expect(find.text('Approved expenses'), findsOneWidget);
      expect(find.text('Pending expenses'), findsOneWidget);
      expect(find.text('Disputed expenses'), findsOneWidget);
      expect(find.text('Confirmed transfers'), findsOneWidget);
      expect(find.text('Unconfirmed transfers'), findsOneWidget);
      expect(find.text('PKR 2,300,000.00'), findsOneWidget);
      expect(find.text('PKR 45,000.00'), findsOneWidget);
      expect(find.text('PKR 150,000.00'), findsOneWidget);
      expect(find.text('PKR 3,500,000.00'), findsOneWidget);
      expect(find.text('PKR 0.00'), findsOneWidget);
    },
  );

  testWidgets('final report generates a PDF and requests the share flow', (
    tester,
  ) async {
    String? method;
    Map<Object?, Object?>? arguments;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, (call) async {
          method = call.method;
          arguments = call.arguments as Map<Object?, Object?>;
          return 1;
        });

    await tester.pumpWidget(
      const MaterialApp(home: FinalProjectReportScreen()),
    );
    await tester.tap(find.byTooltip('Export PDF'));
    await tester.pumpAndSettle();

    expect(method, 'sharePdf');
    expect(arguments?['name'], 'gulshan-villa-project-report.pdf');
    final bytes = arguments?['doc'] as List<int>;
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(
      String.fromCharCodes(bytes.skip(bytes.length - 6)),
      contains('%%EOF'),
    );
  });

  testWidgets('both dashboards open their Phase 9 destinations', (
    tester,
  ) async {
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
    await _tapDashboardAction(tester, 'Final Inspection');
    expect(find.text('Final Inspection & Handover'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: const OwnerDashboardScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
    await _tapDashboardAction(tester, 'Final Report');
    expect(find.text('Final Project Report'), findsOneWidget);

    state.switchRole(UserRole.contractor);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: const ContractorDashboardScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
    await _tapDashboardAction(tester, 'Handover Status');
    expect(find.text('Final Inspection & Handover'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: const ContractorDashboardScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
    await _tapDashboardAction(tester, 'Final Project Report');
    expect(find.text('Final Project Report'), findsOneWidget);
  });

  testWidgets('owner can record inspection feedback', (tester) async {
    final state = AppState();
    state.switchRole(UserRole.owner);

    await tester.pumpWidget(const MaterialApp(home: FinalInspectionScreen()));
    await tester.scrollUntilVisible(
      find.byType(TextField),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byType(TextField),
      'Complete the remaining phases.',
    );
    tester.testTextInput.hide();
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Record Needs Work'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Record Needs Work'));
    await tester.pump();

    expect(state.latestFinalInspection?.approved, isFalse);
    expect(
      state.latestFinalInspection?.feedback,
      'Complete the remaining phases.',
    );
  });

  test(
    'handover readiness, permissions, records, and completion are guarded',
    () {
      final state = AppState();
      state.switchRole(UserRole.owner);

      expect(state.isReadyForHandover, isFalse);
      expect(state.handoverBlockers, contains(contains('Phase 1')));
      expect(state.handoverBlockers, contains(contains('Generator rental')));
      expect(
        state.handoverBlockers,
        contains(contains('PVC pipes and fittings')),
      );
      expect(state.completeProject(), isFalse);
      expect(
        state.recordFinalInspection(approved: false, feedback: '  '),
        isFalse,
      );
      expect(
        state.recordFinalInspection(approved: true, feedback: ''),
        isFalse,
      );
      expect(
        state.recordFinalInspection(
          approved: false,
          feedback: 'Complete the outstanding work.',
        ),
        isTrue,
      );

      state.switchRole(UserRole.contractor);
      expect(
        state.recordFinalInspection(
          approved: false,
          feedback: 'Contractor cannot record this decision.',
        ),
        isFalse,
      );
      expect(
        state.recordFinalInspection(approved: true, feedback: ''),
        isFalse,
      );
      expect(state.completeProject(), isFalse);

      for (var id = 1; id <= 6; id++) {
        state.switchRole(UserRole.contractor);
        expect(state.markMilestoneReady(id), isTrue);
        state.switchRole(UserRole.owner);
        expect(state.signOffMilestone(id), isTrue);
      }

      expect(
        state.allMilestones.every(
          (milestone) => milestone.status == MilestoneStatus.completed,
        ),
        isTrue,
      );

      expect(state.approveExpense('exp_003'), isTrue);
      expect(state.isReadyForHandover, isFalse);
      expect(
        state.recordFinalInspection(approved: true, feedback: ''),
        isFalse,
      );

      state.switchRole(UserRole.contractor);
      expect(
        state.resubmitExpense(
          'exp_002',
          'Equipment',
          145000,
          'Revised generator rental',
          true,
        ),
        isTrue,
      );
      state.switchRole(UserRole.owner);
      expect(state.approveExpense('exp_002'), isTrue);

      expect(state.totalApprovedExpenses, 2490000);
      expect(state.totalPendingExpenses, 0);
      expect(state.totalDisputedExpenses, 0);
      expect(state.approvedExpenses, hasLength(3));
      expect(state.totalConfirmedTransfers, 3500000);

      expect(state.addTransfer(1250.5, 'Final transfer', true), isTrue);
      expect(state.unconfirmedIncomingFunds, 1250.5);
      expect(state.totalConfirmedTransfers, 3500000);
      expect(state.isReadyForHandover, isFalse);
      expect(
        state.recordFinalInspection(
          approved: true,
          feedback: 'Cannot approve while transfer is unconfirmed.',
        ),
        isFalse,
      );
      state.switchRole(UserRole.contractor);
      expect(state.confirmTransfer(state.pendingTransfers.single.id), isTrue);
      state.switchRole(UserRole.owner);

      expect(state.isReadyForHandover, isTrue);
      expect(state.completeProject(), isFalse);
      expect(
        state.recordFinalInspection(
          approved: true,
          feedback: 'All work verified.',
        ),
        isTrue,
      );
      expect(
        state.recordFinalInspection(
          approved: true,
          feedback: 'Duplicate approval.',
        ),
        isFalse,
      );
      expect(state.completeProject(), isTrue);
      expect(state.isProjectCompleted, isTrue);
      expect(state.projectCompletedDate, isNotNull);
      expect(state.completeProject(), isFalse);
      expect(
        state.recordFinalInspection(approved: false, feedback: 'Late change.'),
        isFalse,
      );

      state.switchRole(UserRole.contractor);
      expect(state.completeProject(), isFalse);
      expect(state.addExpense('Materials', 10, 'Late expense', true), isFalse);
      state.switchRole(UserRole.owner);
      expect(state.addTransfer(10, 'Late transfer', true), isFalse);
      state.switchRole(UserRole.contractor);
      expect(state.allTransfers, hasLength(2));
      expect(state.confirmedTransfers, hasLength(2));
      expect(state.unconfirmedIncomingFunds, 0);
    },
  );
}

Future<void> _tapDashboardAction(WidgetTester tester, String action) async {
  final target = find.text(action);
  for (var attempt = 0; attempt < 5; attempt++) {
    final bounds = tester.getRect(target);
    if (bounds.top >= 0 && bounds.bottom <= tester.view.physicalSize.height) {
      break;
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  await tester.tap(target);
  await tester.pumpAndSettle();
}
