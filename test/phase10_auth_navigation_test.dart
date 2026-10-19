import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_management_app/app.dart';
import 'package:construction_management_app/core/navigation/app_router.dart';
import 'package:construction_management_app/models/user_role.dart';
import 'package:construction_management_app/screens/auth/forgot_password_screen.dart';
import 'package:construction_management_app/screens/auth/login_screen.dart';
import 'package:construction_management_app/state/app_state.dart';

void main() {
  test('initial navigation creates only the configured Splash route', () {
    final routes = AppRouter.generateInitialRoutes(AppRouter.initialRoute);

    expect(routes, hasLength(1));
    expect(routes.single.settings.name, AppRouter.initialRoute);
  });

  testWidgets('Login opens Forgot Password and the screen returns to Login', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('Return to Login'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets(
    'Forgot Password validates email and reports a demo-only result',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.textContaining('No email was sent.'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'invalid-address');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'owner@example.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Preparing demo...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Demo request complete. No email was sent.'),
        findsOneWidget,
      );
      expect(find.textContaining('email was sent'), findsOneWidget);
      expect(find.text('Email sent'), findsNothing);
    },
  );

  testWidgets('Owner login Back does not reveal an undefined route', (
    tester,
  ) async {
    final state = AppState();
    state.switchRole(UserRole.owner);

    await _loginFromSplash(tester, state);
    expect(find.text('Project Overview'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Project Overview'), findsOneWidget);
    expect(find.textContaining('No route defined'), findsNothing);
  });

  testWidgets('role switching in Settings and Contractor Back stay in app', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    state.switchRole(UserRole.owner);
    await _loginFromSplash(tester, state);
    expect(find.text('Project Overview'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Active Workspace Role'), findsOneWidget);

    await tester.tap(find.text('Contractor').first);
    await tester.pumpAndSettle();
    expect(find.text('Site Operations'), findsOneWidget);
    expect(state.activeRole, UserRole.contractor);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Site Operations'), findsOneWidget);
    expect(find.textContaining('No route defined'), findsNothing);
  });
}

Future<void> _loginFromSplash(WidgetTester tester, AppState state) async {
  await tester.pumpWidget(ConstructionApp(appState: state));
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  expect(find.text('Sign In'), findsOneWidget);

  await tester.tap(find.text('Login'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}
