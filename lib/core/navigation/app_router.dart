import 'package:flutter/material.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/owner/owner_dashboard_screen.dart';
import '../../screens/contractor/contractor_dashboard_screen.dart';

class AppRouter {
  static const String initialRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String ownerDashboardRoute = '/owner_dashboard';
  static const String contractorDashboardRoute = '/contractor_dashboard';
  
  // Phase 3 Placeholders for Bottom Nav
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