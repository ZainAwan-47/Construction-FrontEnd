import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';

class ActivityNotificationButton extends StatelessWidget {
  const ActivityNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final count = AppState().unreadActivityCount;
        return IconButton(
          tooltip: count == 0
              ? 'Activity'
              : 'Activity, $count unread notifications',
          onPressed: () =>
              AppRouter.pushNamedOnce(context, AppRouter.activityCenterRoute),
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : '$count'),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}
