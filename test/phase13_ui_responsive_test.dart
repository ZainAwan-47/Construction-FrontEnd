import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/core/theme/app_colors.dart';
import 'package:construction_management_app/core/theme/app_theme.dart';
import 'package:construction_management_app/models/expense.dart';
import 'package:construction_management_app/screens/contractor/contractor_dashboard_screen.dart';
import 'package:construction_management_app/screens/contractor/my_expenses_screen.dart';
import 'package:construction_management_app/screens/owner/review_queue_screen.dart';
import 'package:construction_management_app/screens/owner/owner_dashboard_screen.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/state/app_state.dart';
import 'package:construction_management_app/widgets/common/primary_button.dart';
import 'package:construction_management_app/widgets/common/status_badge.dart';
import 'package:construction_management_app/widgets/dashboard/quick_action_card.dart';

void main() {
  testWidgets('primary button and warning badge text meet WCAG AA contrast', (
    tester,
  ) async {
    expect(
      _contrastRatio(AppColors.primaryOrangeForeground, AppColors.surfaceWhite),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(
        AppColors.primaryOrangeForeground,
        AppColors.surfaceWarmGray,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.primaryOrangeForeground, AppColors.lightOrange),
      greaterThanOrEqualTo(4.5),
    );
    final buttonStyle = AppTheme.lightTheme.elevatedButtonTheme.style!;
    final buttonForeground = buttonStyle.foregroundColor!.resolve({});
    final buttonBackground = buttonStyle.backgroundColor!.resolve({});

    expect(buttonForeground, isNotNull);
    expect(buttonBackground, AppColors.primaryOrange);
    expect(
      _contrastRatio(buttonForeground!, buttonBackground!),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.surfaceWhite, AppColors.primaryBlue),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.surfaceWhite, AppColors.success),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.surfaceWhite, AppColors.error),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.surfaceWhite, AppColors.info),
      greaterThanOrEqualTo(4.5),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PrimaryButton(label: 'Cancel', isOutline: true)),
      ),
    );
    final outlinedButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    final outlinedButtonStyle = outlinedButton.style!;
    final outlineColor = outlinedButtonStyle.side!.resolve({})!.color;
    final outlineForeground = outlinedButtonStyle.foregroundColor!.resolve({});
    expect(outlineColor, AppColors.primaryOrangeForeground);
    expect(
      _contrastRatio(outlineColor, AppColors.surfaceWhite),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrastRatio(outlineForeground!, AppColors.surfaceWhite),
      greaterThanOrEqualTo(4.5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: Center(
            child: StatusBadge(status: BadgeStatus.pending, text: 'Pending'),
          ),
        ),
      ),
    );

    final badgeText = tester.widget<Text>(find.text('Pending'));
    expect(badgeText.style?.color, AppColors.textPrimary);
    expect(
      _contrastRatio(badgeText.style!.color!, AppColors.warning),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('shared expense badges preserve status labels and icons', (
    tester,
  ) async {
    final badges = [
      StatusBadge.forExpense(ExpenseStatus.pending),
      StatusBadge.forExpense(ExpenseStatus.approved),
      StatusBadge.forExpense(ExpenseStatus.disputed),
    ];

    expect(badges.map((badge) => badge.status), [
      BadgeStatus.pending,
      BadgeStatus.approved,
      BadgeStatus.disputed,
    ]);
    expect(badges.map((badge) => badge.icon), [
      Icons.hourglass_empty,
      Icons.check_circle_outline,
      Icons.error_outline,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Row(children: badges)),
      ),
    );

    for (final label in ['Pending', 'Approved', 'Disputed']) {
      expect(find.text(label), findsOneWidget);
    }
    final expectedForegrounds = {
      'Pending': AppColors.textPrimary,
      'Approved': AppColors.surfaceWhite,
      'Disputed': AppColors.surfaceWhite,
    };
    final expectedBackgrounds = {
      'Pending': AppColors.warning,
      'Approved': AppColors.success,
      'Disputed': AppColors.error,
    };
    for (final label in expectedForegrounds.keys) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.style?.color, expectedForegrounds[label]);
      final badgeContainer = tester.widget<Container>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
      expect(
        (badgeContainer.decoration! as BoxDecoration).color,
        expectedBackgrounds[label],
      );
    }
  });

  testWidgets('expense list and review warning badges use readable text', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MyExpensesScreen()));

    var badgeText = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Pending' &&
            widget.style?.color == AppColors.textPrimary,
      ),
    );
    expect(badgeText.style?.color, AppColors.textPrimary);
    expect(
      _contrastRatio(badgeText.style!.color!, AppColors.warning),
      greaterThanOrEqualTo(4.5),
    );

    await tester.pumpWidget(const MaterialApp(home: ReviewQueueScreen()));

    badgeText = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Pending' &&
            widget.style?.color == AppColors.textPrimary,
      ),
    );
    expect(badgeText.style?.color, AppColors.textPrimary);
    expect(
      _contrastRatio(badgeText.style!.color!, AppColors.warning),
      greaterThanOrEqualTo(4.5),
    );
  });

  for (final layout in [
    (name: 'narrow phone', size: const Size(320, 800), textScale: 1.0),
    (name: 'typical phone', size: const Size(390, 844), textScale: 1.0),
    (name: 'enlarged text', size: const Size(390, 844), textScale: 1.6),
  ]) {
    testWidgets(
      'owner and contractor dashboards fit quick actions at ${layout.name}',
      (tester) async {
        tester.view.physicalSize = layout.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final configuration in [
          (role: UserRole.owner, dashboard: const OwnerDashboardScreen()),
          (
            role: UserRole.contractor,
            dashboard: const ContractorDashboardScreen(),
          ),
        ]) {
          AppState().switchRole(configuration.role);
          await tester.pumpWidget(
            MaterialApp(
              home: configuration.dashboard,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(layout.textScale)),
                child: child!,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          final cards = find.byType(QuickActionCard);
          expect(cards, findsAtLeastNWidgets(2));

          final firstTitle = find.text(
            configuration.role == UserRole.owner
                ? 'Final Report'
                : 'New Expense',
          );
          final mediaQuery = MediaQuery.of(tester.element(firstTitle));
          expect(mediaQuery.size, layout.size);
          expect(
            mediaQuery.textScaler.scale(14),
            closeTo(14 * layout.textScale, 0.01),
          );
          final navigationItems = tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .items
              .map((item) => item.label)
              .toList();
          final bottomNavigation = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(
            _contrastRatio(
              bottomNavigation.selectedItemColor!,
              AppColors.surfaceWhite,
            ),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrastRatio(
              bottomNavigation.unselectedItemColor!,
              AppColors.surfaceWhite,
            ),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            navigationItems,
            configuration.role == UserRole.owner
                ? ['Home', 'Funds', 'Review', 'Milestones', 'Settings']
                : ['Home', 'Expenses', 'Milestones', 'Settings'],
          );

          final firstCard = tester.getRect(cards.first);
          final secondCard = tester.getRect(cards.at(1));
          if (layout.size.width == 320) {
            expect(firstCard.width, greaterThan(250));
            expect(secondCard.top, greaterThan(firstCard.top));
          } else {
            expect(firstCard.width, lessThan(220));
            expect(secondCard.top, closeTo(firstCard.top, 1));
          }

          for (final title in [
            'Final Report',
            'Final Inspection',
            'New Expense',
            'Handover Status',
            'Final Project Report',
          ]) {
            final titleFinder = find.descendant(
              of: cards,
              matching: find.text(title),
            );
            if (titleFinder.evaluate().isNotEmpty) {
              final titleRect = tester.getRect(titleFinder.first);
              final cardRect = tester.getRect(
                find.ancestor(
                  of: titleFinder.first,
                  matching: find.byType(QuickActionCard),
                ),
              );
              expect(cardRect.contains(titleRect.topLeft), isTrue);
              expect(cardRect.contains(titleRect.bottomRight), isTrue);
            }
          }
        }
      },
    );
  }

  testWidgets('My Expenses empty state opens Create Expense', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MyExpensesScreen.withExpenses(expenses: []),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );

    expect(find.text('No expenses yet'), findsOneWidget);
    expect(
      find.textContaining('Create an expense and attach its demo receipt'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Create Expense'), findsOneWidget);
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
