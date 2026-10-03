import 'package:flutter/material.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/status_badge.dart';

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏗️ Construction App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foundation Verified',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('UI Component Test'),
                  SizedBox(height: 8),
                  StatusBadge(status: BadgeStatus.approved, text: '✅ Approved'),
                  SizedBox(height: 8),
                  StatusBadge(status: BadgeStatus.pending, text: '⏳ Pending'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Primary Button Test',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Outline Button Test',
              isOutline: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}