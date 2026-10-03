import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'state/app_state.dart';

class ConstructionApp extends StatelessWidget {
  final AppState appState;

  const ConstructionApp({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Construction Management',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}