import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/app.dart';
import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/core/theme/app_theme.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/screens/contractor/contractor_dashboard_screen.dart';
import 'package:construction_management_app/screens/owner/owner_dashboard_screen.dart';
import 'package:construction_management_app/state/app_state.dart';
import 'package:construction_management_app/widgets/navigation/animated_tab_stack.dart';
import 'package:construction_management_app/widgets/navigation/role_bottom_nav.dart';

void main() {
  testWidgets('named routes deduplicate rapid pushes and reverse cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final observer = _RecordingNavigatorObserver();
    AppState().switchRole(UserRole.owner);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.ownerDashboardRoute,
        onGenerateInitialRoutes: AppRouter.generateInitialRoutes,
        onGenerateRoute: AppRouter.generateRoute,
        navigatorObservers: [observer],
      ),
    );
    await tester.pumpAndSettle();

    final homeContext = tester.element(find.text('Project Overview'));
    final initialPushCount = observer.pushes.length;
    await tester.tap(find.text('Final Report'));
    await tester.pump();
    AppRouter.pushNamedOnce(homeContext, AppRouter.finalProjectReportRoute);
    await tester.pump();

    final pushedRoutes = observer.pushes.skip(initialPushCount).toList();
    expect(pushedRoutes, hasLength(1));
    final route = pushedRoutes.single as PageRoute<dynamic>;
    expect(route.transitionDuration, const Duration(milliseconds: 250));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 250));

    await tester.pump(const Duration(milliseconds: 100));
    expect(route.animation!.value, greaterThan(0));
    expect(route.animation!.value, lessThan(1));
    final previousRoute =
        observer.pushes[initialPushCount - 1] as PageRoute<dynamic>;
    final slideOffsets = tester
        .widgetList<SlideTransition>(find.byType(SlideTransition))
        .map((transition) => transition.position.value.dx)
        .toList();
    expect(previousRoute.secondaryAnimation!.value, greaterThan(0));
    expect(slideOffsets.any((offset) => offset > 0), isTrue);
    expect(slideOffsets.any((offset) => offset < 0), isTrue);
    final incomingOffset = slideOffsets.firstWhere((offset) => offset > 0);
    final outgoingOffset = slideOffsets.firstWhere((offset) => offset < 0);
    expect(incomingOffset, closeTo(1 + outgoingOffset, 0.02));
    expect(find.byType(FadeTransition), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Final Project Report'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    expect(observer.pops, hasLength(1));
    // The popped route's controller should now be running in reverse.
    expect(route.animation!.status, AnimationStatus.reverse);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(route.animation!.value, greaterThan(0));
    expect(route.animation!.value, lessThan(1));
    final reverseOffsets = tester
        .widgetList<SlideTransition>(find.byType(SlideTransition))
        .map((transition) => transition.position.value.dx)
        .toList();
    expect(reverseOffsets.any((offset) => offset > 0), isTrue);
    expect(reverseOffsets.any((offset) => offset < 0), isTrue);
    expect(
      reverseOffsets.firstWhere((offset) => offset > 0),
      closeTo(1 + reverseOffsets.firstWhere((offset) => offset < 0), 0.02),
    );
    expect(find.byType(FadeTransition), findsNothing);
    AppRouter.pushNamedOnce(homeContext, AppRouter.finalProjectReportRoute);
    await tester.pump();
    expect(observer.pushes, hasLength(initialPushCount + 1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(route.animation!.value, greaterThan(0));
    expect(route.animation!.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(find.text('Project Overview'), findsOneWidget);
    expect(observer.pushes, hasLength(initialPushCount + 1));

    AppRouter.pushNamedOnce(homeContext, AppRouter.createExpenseRoute);
    await tester.pump();
    expect(observer.pushes, hasLength(initialPushCount + 2));
    await tester.pumpAndSettle();
    expect(find.text('Create Expense'), findsOneWidget);
  });

  testWidgets('tab switching stays on one route and keeps role destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final role in [UserRole.owner, UserRole.contractor]) {
      final observer = _RecordingNavigatorObserver();
      AppState().switchRole(role);
      await tester.pumpWidget(
        MaterialApp(
          home: role == UserRole.owner
              ? const OwnerDashboardScreen()
              : const ContractorDashboardScreen(),
          onGenerateRoute: AppRouter.generateRoute,
          navigatorObservers: [observer],
        ),
      );
      await tester.pumpAndSettle();
      final initialPushCount = observer.pushes.length;

      final labels = role == UserRole.owner
          ? ['Funds', 'Review', 'Milestones', 'Settings', 'Home']
          : ['Expenses', 'Milestones', 'Settings', 'Home'];
      for (final label in labels) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
      }

      final navigation = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navigation.currentIndex, 0);
      expect(observer.pushes, hasLength(initialPushCount));
      expect(find.byType(RoleBottomNav), findsOneWidget);
    }
  });

  testWidgets('tab content glides on rapid changes and retains scroll offset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: _AnimatedTabsHarness(scrollController: scrollController),
      ),
    );

    expect(find.byKey(const ValueKey('tab-0')), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();
    final savedOffset = scrollController.offset;
    expect(savedOffset, greaterThan(0));

    final pageView = tester.widget<PageView>(find.byType(PageView));
    final pageController = pageView.controller!;
    await tester.tap(find.text('Second tab'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(pageController.page, greaterThan(0));
    expect(pageController.page, lessThan(1));
    expect(find.byType(AnimatedOpacity), findsNothing);

    await tester.tap(find.text('Third tab'));
    await tester.pump(const Duration(milliseconds: 80));
    final pageBeforeBackTap = pageController.page!;
    await tester.tap(find.text('First tab'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(pageController.page, lessThan(pageBeforeBackTap));
    expect(
      find.descendant(
        of: find.byType(PageView),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();

    expect(find.text('Selected tab: 0'), findsOneWidget);
    expect(pageController.page, 0);
    expect(scrollController.offset, savedOffset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppState updates do not replace the active app route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    state.switchRole(UserRole.owner);
    await tester.pumpWidget(ConstructionApp(appState: state));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Project Overview'), findsOneWidget);

    await tester.tap(find.text('Final Report'));
    await tester.pumpAndSettle();
    expect(find.text('Final Project Report'), findsOneWidget);

    final navigatorBeforeUpdate = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    expect(
      state.updateDemoProfile(name: 'QA Owner', email: 'qa@example.com'),
      isTrue,
    );
    await tester.pump();

    final navigatorAfterUpdate = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    expect(identical(navigatorBeforeUpdate, navigatorAfterUpdate), isTrue);
    expect(find.text('Final Project Report'), findsOneWidget);
  });

  test('same-role updates do not emit redundant state notifications', () {
    final state = AppState();
    state.switchRole(UserRole.owner);
    var notifications = 0;
    void listener() => notifications++;

    state.addListener(listener);
    state.switchRole(state.activeRole);
    expect(notifications, 0);

    state.switchRole(UserRole.contractor);
    expect(notifications, 1);
    state.removeListener(listener);
    state.switchRole(UserRole.owner);
  });
}

class _AnimatedTabsHarness extends StatefulWidget {
  final ScrollController scrollController;

  const _AnimatedTabsHarness({required this.scrollController});

  @override
  State<_AnimatedTabsHarness> createState() => _AnimatedTabsHarnessState();
}

class _AnimatedTabsHarnessState extends State<_AnimatedTabsHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => setState(() => _index = 0),
              child: const Text('First tab'),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 1),
              child: const Text('Second tab'),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 2),
              child: const Text('Third tab'),
            ),
          ],
        ),
        Text('Selected tab: $_index'),
        Expanded(
          child: AnimatedTabStack(
            index: _index,
            children: [
              Container(
                key: const ValueKey('tab-0'),
                child: ListView(
                  controller: widget.scrollController,
                  children: [
                    const Center(child: Text('First tab selected')),
                    ...List<Widget>.generate(
                      30,
                      (index) => SizedBox(
                        height: 48,
                        child: Text('First tab row $index'),
                      ),
                    ),
                  ],
                ),
              ),
              const Center(
                key: ValueKey('tab-1'),
                child: Text('Second tab selected'),
              ),
              const Center(
                key: ValueKey('tab-2'),
                child: Text('Third tab selected'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushes = [];
  final List<Route<dynamic>> pops = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pops.add(route);
    super.didPop(route, previousRoute);
  }
}
