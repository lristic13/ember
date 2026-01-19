import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;

class HeatmapCell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = gradient.getColorsForIntensity(intensity);
    final isFuture = date_utils.DateUtils.isFuture(date);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use theme-aware color for empty cells (intensity 0)
    // In light mode, use a light gray instead of dark gradient color
    final cellColor = intensity <= 0 && !isDarkMode
        ? const Color(0xFFE8E8E8)
        : colors.cellColor;

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: Opacity(
        opacity: isFuture ? 0.3 : 1.0,
        child: Container(
          width: AppDimensions.weekHeatMapCellSize,
          height: AppDimensions.weekHeatMapCellSize,
          decoration: BoxDecoration(
            color: cellColor,
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
      ),
    );
  }
}
