import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/habit_gradients.dart';

class MonthHeatmapCell extends StatelessWidget {
  final int? dayNumber;
  final double intensity;
  final bool isToday;
  final bool isOutsideMonth;
  final HabitGradient gradient;
  final VoidCallback? onTap;

  const MonthHeatmapCell({
    super.key,
    this.dayNumber,
    required this.intensity,
    this.isToday = false,
    this.isOutsideMonth = false,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dayNumber == null || isOutsideMonth) {
      return const SizedBox(
        width: AppDimensions.monthHeatMapCellSize,
        height: AppDimensions.monthHeatMapCellSize,
      );
    }

    final colors = gradient.getColorsForIntensity(intensity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.monthHeatMapCellSize,
        height: AppDimensions.monthHeatMapCellSize,
        decoration: BoxDecoration(
          color: colors.cellColor,
          borderRadius: BorderRadius.circular(
            AppDimensions.monthHeatMapCellRadius,
          ),
          border: isToday
              ? Border.all(color: gradient.primaryColor, width: 2)
              : null,
          boxShadow: colors.glowColor != null
              ? [
                  BoxShadow(
                    color: colors.glowColor!.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          dayNumber.toString(),
          style: AppTextStyles.labelSmall.copyWith(
            color: intensity > 0.5
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
