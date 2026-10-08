// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/app.dart';
import 'package:construction_management_app/core/formatters/currency_formatter.dart';
import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/screens/contractor/contractor_dashboard_screen.dart';
import 'package:construction_management_app/screens/owner/owner_dashboard_screen.dart';
import 'package:construction_management_app/state/app_state.dart';

void main() {
  testWidgets('app displays the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(ConstructionApp(appState: AppState()));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Owner can open Settings from the dashboard navigation', (tester) async {
    await _openSettingsForRole(tester, UserRole.owner);
    expect(find.text('Active Workspace Role'), findsOneWidget);
  });

  testWidgets('Contractor can open Settings from the dashboard navigation', (tester) async {
    await _openSettingsForRole(tester, UserRole.contractor);
    expect(find.text('Active Workspace Role'), findsOneWidget);
  });

  test('PKR parser and formatter preserve valid decimal values', () {
    expect(parsePositivePkrAmount('1,234.56'), 1234.56);
    expect(parsePositivePkrAmount('0.125'), 0.125);
    expect(formatPkrCurrency(1234.56), 'PKR 1,234.56');
    expect(formatPkrCurrency(1234.5), 'PKR 1,234.50');
  });

  test('PKR parser rejects invalid, non-finite, zero, and negative values', () {
    for (final input in [
      'NaN',
      'Infinity',
      '-Infinity',
      '0',
      '-1',
      'not an amount',
      '1,2',
    ]) {
      expect(parsePositivePkrAmount(input), isNull, reason: input);
    }
  });

  test('AppState rejects non-finite, zero, and negative amounts', () {
    final state = AppState();
    final invalidAmounts = [
      double.nan,
      double.infinity,
      double.negativeInfinity,
      0.0,
      -1.0,
    ];

    state.switchRole(UserRole.owner);
    for (final amount in invalidAmounts) {
      expect(state.addTransfer(amount, 'Test', true), isFalse);
    }

    state.switchRole(UserRole.contractor);
    for (final amount in invalidAmounts) {
      expect(state.addExpense('Materials', amount, 'Test', true), isFalse);
      expect(
        state.resubmitExpense('exp_002', 'Equipment', amount, 'Test', true),
        isFalse,
      );
    }
    state.switchRole(UserRole.owner);
  });
}

Future<void> _openSettingsForRole(WidgetTester tester, UserRole role) async {
  AppState().switchRole(role);
  final dashboard = role == UserRole.owner
      ? const OwnerDashboardScreen()
      : const ContractorDashboardScreen();
  await tester.pumpWidget(
    MaterialApp(
      home: dashboard,
      onGenerateRoute: AppRouter.generateRoute,
    ),
  );
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
}
