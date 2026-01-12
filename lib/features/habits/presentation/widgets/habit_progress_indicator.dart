import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/tracking_type.dart';

class HabitProgressIndicator extends StatelessWidget {
  final double currentValue;
  final TrackingType trackingType;
  final String? unit;
  final Color color;

  const HabitProgressIndicator({
    super.key,
    required this.currentValue,
    required this.trackingType,
    this.unit,
    required this.color,
  });

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _getText() {
    final hasValue = currentValue > 0;

    if (trackingType == TrackingType.completion) {
      return hasValue ? AppStrings.completed : AppStrings.notDoneToday;
    }

    // Quantity type
    return '${_formatNumber(currentValue)} ${unit ?? ''} today';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = currentValue > 0;

    return Text(
      _getText(),
      style: AppTextStyles.bodySmall.copyWith(
        color: hasValue ? color : AppColors.textSecondary,
        fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
