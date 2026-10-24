import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/owner/owner_dashboard_screen.dart';
import '../../screens/contractor/contractor_dashboard_screen.dart';
import '../../screens/owner/send_funds_screen.dart';
import '../../screens/contractor/create_expense_screen.dart';
import '../../screens/contractor/my_expenses_screen.dart';
import '../../screens/contractor/adjust_disputed_expense_screen.dart';
import '../../screens/owner/review_queue_screen.dart';
import '../../screens/owner/expense_detail_screen.dart';
import '../../widgets/common/milestone_tracker_screen.dart';
import '../../widgets/common/milestone_detail_screen.dart';
import '../../screens/common/settings_screen.dart';
import '../../screens/common/activity_center_screen.dart';
import '../../screens/common/final_inspection_screen.dart';
import '../../screens/common/final_project_report_screen.dart';

class AppRouter {
  static final Expando<Set<String>> _pendingNamedRoutes = Expando<Set<String>>(
    'pending named routes',
  );

  static const String initialRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot_password';
  static const String ownerDashboardRoute = '/owner_dashboard';
  static const String contractorDashboardRoute = '/contractor_dashboard';
  static const String sendFundsRoute = '/send_funds';
  static const String createExpenseRoute = '/create_expense';
  static const String myExpensesRoute = '/my_expenses';
  static const String adjustExpenseRoute = '/adjust_expense';
  static const String reviewQueueRoute = '/review_queue';
  static const String expenseDetailRoute = '/expense_detail';
  static const String milestoneTrackerRoute = '/milestone_tracker';
  static const String milestoneDetailRoute = '/milestone_detail';
  static const String settingsRoute = '/settings';
  static const String activityCenterRoute = '/activity';
  static const String finalInspectionRoute = '/final_inspection';
  static const String finalProjectReportRoute = '/final_project_report';
  static const String placeholderRoute = '/placeholder';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return _buildRoute(settings, (_) => const SplashScreen());
      case loginRoute:
        return _buildRoute(settings, (_) => const LoginScreen());
      case signupRoute:
        return _buildRoute(settings, (_) => const SignupScreen());
      case forgotPasswordRoute:
        return _buildRoute(settings, (_) => const ForgotPasswordScreen());
      case ownerDashboardRoute:
        return _buildRoute(settings, (_) => const OwnerDashboardScreen());
      case contractorDashboardRoute:
        return _buildRoute(settings, (_) => const ContractorDashboardScreen());
      case sendFundsRoute:
        return _buildRoute(settings, (_) => const SendFundsScreen());
      case createExpenseRoute:
        return _buildRoute(settings, (_) => const CreateExpenseScreen());
      case myExpensesRoute:
        return _buildRoute(settings, (_) => const MyExpensesScreen());
      case adjustExpenseRoute:
        final expenseId = settings.arguments as String;
        return _buildRoute(
          settings,
          (_) => AdjustDisputedExpenseScreen(expenseId: expenseId),
        );
      case reviewQueueRoute:
        return _buildRoute(settings, (_) => const ReviewQueueScreen());
      case expenseDetailRoute:
        final expenseId = settings.arguments as String;
        return _buildRoute(
          settings,
          (_) => ExpenseDetailScreen(expenseId: expenseId),
        );
      case milestoneTrackerRoute:
        return _buildRoute(settings, (_) => const MilestoneTrackerScreen());
      case milestoneDetailRoute:
        final milestoneId = settings.arguments as int;
        return _buildRoute(
          settings,
          (_) => MilestoneDetailScreen(milestoneId: milestoneId),
        );
      case settingsRoute:
        return _buildRoute(settings, (_) => const SettingsScreen());
      case activityCenterRoute:
        return _buildRoute(settings, (_) => const ActivityCenterScreen());
      case finalInspectionRoute:
        return _buildRoute(settings, (_) => const FinalInspectionScreen());
      case finalProjectReportRoute:
        return _buildRoute(settings, (_) => const FinalProjectReportScreen());
      case placeholderRoute:
        return _buildRoute(
          settings,
          (_) => Scaffold(
            backgroundColor: AppColors.surfaceWarmGray,
            appBar: AppBar(title: const Text('Feature Pending')),
            body: const Center(
              child: Text('This feature belongs to a later phase.'),
            ),
          ),
        );
      default:
        return _buildRoute(
          settings,
          (_) => Scaffold(
            backgroundColor: AppColors.surfaceWarmGray,
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Future<T?> pushNamedOnce<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    final navigator = Navigator.of(context);
    final pendingRoutes = _pendingNamedRoutes[navigator] ??= <String>{};
    if (!pendingRoutes.add(routeName)) return Future<T?>.value(null);

    try {
      return navigator.pushNamed<T>(routeName, arguments: arguments);
    } on Object {
      pendingRoutes.remove(routeName);
      rethrow;
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return _AppPageRoute(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, _) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (settings.name == initialRoute) return child;
        final incomingAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        );
        final outgoingAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(incomingAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1, 0),
            ).animate(outgoingAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static List<Route<dynamic>> generateInitialRoutes(String initialRoute) => [
    generateRoute(RouteSettings(name: initialRoute)),
  ];
}

class _AppPageRoute extends PageRouteBuilder<dynamic> {
  _AppPageRoute({
    required super.settings,
    required super.transitionDuration,
    required super.reverseTransitionDuration,
    required super.pageBuilder,
    required super.transitionsBuilder,
  });

  @override
  void dispose() {
    final navigator = this.navigator;
    final routeName = settings.name;
    if (navigator != null && routeName != null) {
      AppRouter._pendingNamedRoutes[navigator]?.remove(routeName);
    }
    super.dispose();
  }
}
