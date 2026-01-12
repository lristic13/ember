import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HabitProgressIndicator extends StatelessWidget {
  final double currentValue;
  final String unit;
  final Color color;

  const HabitProgressIndicator({
    super.key,
    required this.currentValue,
    required this.unit,
    required this.color,
  });

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = currentValue > 0;

    return Text(
      '${_formatNumber(currentValue)} $unit today',
      style: AppTextStyles.bodySmall.copyWith(
        color: hasValue ? color : AppColors.textSecondary,
        fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
