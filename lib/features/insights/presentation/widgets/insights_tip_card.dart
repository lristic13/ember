import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/activity_insight.dart';

class InsightsTipCard extends StatelessWidget {
  final List<ActivityInsight> insights;

  const InsightsTipCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final top = insights.first;
    final gradient = top.activity.gradient;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: gradient.max.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: gradient.max.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "You showed up the most for ",
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                children: [
                  TextSpan(
                    text: top.activity.name,
                    style: TextStyle(
                      color: gradient.max,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
