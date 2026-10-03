import 'package:flutter/material.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/owner/owner_dashboard_screen.dart';
import '../../screens/contractor/contractor_dashboard_screen.dart';
import '../../screens/owner/send_funds_screen.dart'; 
import '../../screens/contractor/create_expense_screen.dart';
import '../../screens/contractor/my_expenses_screen.dart';
import '../../screens/owner/review_queue_screen.dart'; // Phase 6
import '../../screens/owner/expense_detail_screen.dart'; // Phase 6

class AppRouter {
  static const String initialRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String ownerDashboardRoute = '/owner_dashboard';
  static const String contractorDashboardRoute = '/contractor_dashboard';
  static const String sendFundsRoute = '/send_funds'; 
  static const String createExpenseRoute = '/create_expense'; 
  static const String myExpensesRoute = '/my_expenses'; 
  static const String reviewQueueRoute = '/review_queue'; // Phase 6
  static const String expenseDetailRoute = '/expense_detail'; // Phase 6
  static const String placeholderRoute = '/placeholder';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signupRoute:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case ownerDashboardRoute:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
      case contractorDashboardRoute:
        return MaterialPageRoute(builder: (_) => const ContractorDashboardScreen());
      case sendFundsRoute:
        return MaterialPageRoute(builder: (_) => const SendFundsScreen());
      case createExpenseRoute:
        return MaterialPageRoute(builder: (_) => const CreateExpenseScreen());
      case myExpensesRoute:
        return MaterialPageRoute(builder: (_) => const MyExpensesScreen());
      case reviewQueueRoute:
        return MaterialPageRoute(builder: (_) => const ReviewQueueScreen());
      case expenseDetailRoute:
        final expenseId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expenseId: expenseId));
      case placeholderRoute:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Feature Pending')),
            body: const Center(child: Text('This feature belongs to a later phase.')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}