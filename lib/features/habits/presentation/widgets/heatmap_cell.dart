import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/habit_gradients.dart';

class HeatmapCell extends StatelessWidget {
  final DateTime date;
  final double intensity;
  final bool isToday;
  final HabitGradient gradient;
  final VoidCallback? onTap;

  const HeatmapCell({
    super.key,
    required this.date,
    required this.intensity,
    required this.isToday,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient.getColorsForIntensity(intensity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.weekHeatMapCellSize,
        height: AppDimensions.weekHeatMapCellSize,
        decoration: BoxDecoration(
          color: colors.cellColor,
          borderRadius: BorderRadius.circular(
            AppDimensions.weekHeatMapCellRadius,
          ),
          border: isToday
              ? Border.all(
                  color: gradient.primaryColor,
                  width: AppDimensions.weekHeatMapTodayBorderWidth,
                )
              : null,
          boxShadow: colors.glowColor != null
              ? [
                  BoxShadow(
                    color: colors.glowColor!.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
