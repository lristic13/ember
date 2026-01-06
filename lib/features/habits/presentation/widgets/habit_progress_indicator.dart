import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HabitProgressIndicator extends StatelessWidget {
  final double currentValue;
  final double dailyGoal;
  final String unit;

  const HabitProgressIndicator({
    super.key,
    required this.currentValue,
    required this.dailyGoal,
    required this.unit,
  });

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = dailyGoal > 0 ? currentValue / dailyGoal : 0.0;
    final isComplete = percentage >= 1.0;

    return Text(
      '${_formatNumber(currentValue)}/${_formatNumber(dailyGoal)} $unit',
      style: AppTextStyles.bodySmall.copyWith(
        color: isComplete ? AppColors.accent : AppColors.textSecondary,
        fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
