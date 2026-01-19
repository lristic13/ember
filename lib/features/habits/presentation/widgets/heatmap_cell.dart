import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import 'animated_fill_container.dart';

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

    // Background color for empty cells (theme-aware)
    final backgroundColor = isDarkMode
        ? gradient.none
        : const Color(0xFFE8E8E8);

    // Fill color from gradient
    final fillColor = colors.cellColor;

    // Show glow for high intensity
    final showGlow = colors.glowColor != null;

    final borderRadius = BorderRadius.circular(
      AppDimensions.weekHeatMapCellRadius,
    );

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: Opacity(
        opacity: isFuture ? 0.3 : 1.0,
        child: AnimatedFillContainer(
          intensity: intensity,
          fillColor: fillColor,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          width: AppDimensions.weekHeatMapCellSize,
          height: AppDimensions.weekHeatMapCellSize,
          glowColor: colors.glowColor,
          showGlow: showGlow,
          border: isToday
              ? Border.all(
                  color: gradient.primaryColor,
                  width: AppDimensions.weekHeatMapTodayBorderWidth,
                )
              : null,
        ),
      ),
    );
  }
}
