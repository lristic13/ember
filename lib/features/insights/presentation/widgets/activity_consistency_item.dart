import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/activity_insight.dart';

class ActivityConsistencyItem extends StatelessWidget {
  final ActivityInsight insight;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const ActivityConsistencyItem({
    super.key,
    required this.insight,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = insight.activity.gradient;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: isHighlighted
              ? gradient.max.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: isHighlighted
              ? Border.all(color: gradient.max, width: 1)
              : Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity name row
            Row(
              children: [
                Text(
                  insight.activity.emoji ?? '',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppDimensions.paddingSm),
                Expanded(
                  child: Text(
                    insight.activity.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${insight.consistencyPercent.round()}%',
                  style: TextStyle(
                    color: gradient.max,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSm),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              child: LinearProgressIndicator(
                value: insight.consistencyPercent / 100,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation(gradient.max),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXs),

            // Days logged
            Text(
              '${insight.daysLogged} of ${insight.totalDays} days',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
