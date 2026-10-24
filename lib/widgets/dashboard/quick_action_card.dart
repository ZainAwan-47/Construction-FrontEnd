import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primaryBlue : AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: isPrimary
                    ? AppColors.surfaceWhite
                    : AppColors.primaryOrange,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? AppColors.surfaceWhite
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isPrimary ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  final List<Widget> children;

  const QuickActionGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (children.isEmpty) return const SizedBox.shrink();

        const spacing = 12.0;
        const minimumTileWidth = 160.0;
        final columns =
            ((constraints.maxWidth + spacing) / (minimumTileWidth + spacing))
                .floor()
                .clamp(1, children.length);
        final rows = <Widget>[];

        for (var start = 0; start < children.length; start += columns) {
          final rowChildren = <Widget>[];
          for (var column = 0; column < columns; column++) {
            if (column > 0) rowChildren.add(const SizedBox(width: spacing));
            final childIndex = start + column;
            rowChildren.add(
              Expanded(
                child: childIndex < children.length
                    ? children[childIndex]
                    : const SizedBox.shrink(),
              ),
            );
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowChildren,
              ),
            ),
          );
          if (start + columns < children.length) {
            rows.add(const SizedBox(height: spacing));
          }
        }

        return Column(children: rows);
      },
    );
  }
}
