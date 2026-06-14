import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/habit_gradients.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../common/animated_fill_container.dart';

/// A single day cell in the mini month heat map.
class MiniMonthCell extends StatelessWidget {
  final DateTime? date;
  final DateTime today;
  final double cellSize;
  final Map<DateTime, double> entriesByDate;
  final Map<DateTime, double> intensitiesByDate;
  final HabitGradient gradient;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const MiniMonthCell({
    super.key,
    required this.date,
    required this.today,
    required this.cellSize,
    required this.entriesByDate,
    required this.intensitiesByDate,
    required this.gradient,
    required this.onCellTap,
  });

  double _getValueForDate(DateTime date) {
    final normalizedDate = date_utils.DateUtils.dateOnly(date);
    return entriesByDate[normalizedDate] ?? 0;
  }

  double _getIntensityForDate(DateTime date) {
    final normalizedDate = date_utils.DateUtils.dateOnly(date);
    return intensitiesByDate[normalizedDate] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final date = this.date;
    if (date == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final theme = Theme.of(context);
    final value = _getValueForDate(date);
    final intensity = _getIntensityForDate(date);
    final colors = gradient.getColorsForIntensity(intensity);
    final isToday = date_utils.DateUtils.isSameDay(date, today);
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

    final borderRadius = BorderRadius.circular(AppDimensions.miniMonthCellRadius);

    return GestureDetector(
      onTap: isFuture ? null : (onCellTap != null ? () => onCellTap!(date, value) : null),
      child: Opacity(
        opacity: isFuture ? 0.3 : 1.0,
        child: AnimatedFillContainer(
          intensity: intensity,
          fillColor: fillColor,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          width: cellSize,
          height: cellSize,
          glowColor: colors.glowColor,
          showGlow: showGlow,
          border: isToday
              ? Border.all(color: gradient.primaryColor, width: 1)
              : null,
        ),
      ),
    );
  }
}
