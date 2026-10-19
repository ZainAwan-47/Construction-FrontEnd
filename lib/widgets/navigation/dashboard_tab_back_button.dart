import 'package:flutter/material.dart';

class DashboardTabNavigation extends InheritedWidget {
  final bool canGoBack;
  final VoidCallback onBack;

  const DashboardTabNavigation({
    super.key,
    required this.canGoBack,
    required this.onBack,
    required super.child,
  });

  static DashboardTabNavigation? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardTabNavigation>();

  @override
  bool updateShouldNotify(DashboardTabNavigation oldWidget) =>
      canGoBack != oldWidget.canGoBack || onBack != oldWidget.onBack;
}

class DashboardTabBackButton extends StatelessWidget {
  const DashboardTabBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tabNavigation = DashboardTabNavigation.maybeOf(context);
    if (tabNavigation != null) {
      return tabNavigation.canGoBack
          ? BackButton(onPressed: tabNavigation.onBack)
          : const SizedBox.shrink();
    }

    return Navigator.of(context).canPop()
        ? const BackButton()
        : const SizedBox.shrink();
  }
}
