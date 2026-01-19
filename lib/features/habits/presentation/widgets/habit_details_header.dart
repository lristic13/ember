import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/habit.dart';
import 'habit_emoji.dart';

class HabitDetailsHeader extends StatelessWidget {
  final Habit habit;

  const HabitDetailsHeader({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        HabitEmoji(emoji: habit.emoji, color: habit.gradient.primaryColor),
        const SizedBox(height: AppDimensions.paddingMd),
        Text(
          habit.name,
          style: AppTextStyles.headlineLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        Text(
          habit.isQuantity ? 'Tracking: ${habit.unit}' : 'Tracking: Yes / No',
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
