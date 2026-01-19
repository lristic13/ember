import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/habit_gradients.dart';

class MonthHeatmapCell extends StatelessWidget {
  final int? dayNumber;
  final double intensity;
  final bool isToday;
  final bool isOutsideMonth;
  final bool isFuture;
  final HabitGradient gradient;
  final VoidCallback? onTap;

  const MonthHeatmapCell({
    super.key,
    this.dayNumber,
    required this.intensity,
    this.isToday = false,
    this.isOutsideMonth = false,
    this.isFuture = false,
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

    final theme = Theme.of(context);
    final colors = gradient.getColorsForIntensity(intensity);
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
          width: AppDimensions.monthHeatMapCellSize,
          height: AppDimensions.monthHeatMapCellSize,
          decoration: BoxDecoration(
            color: cellColor,
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
              color: _getTextColor(theme, isDarkMode, intensity),
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(ThemeData theme, bool isDarkMode, double intensity) {
    if (isDarkMode) {
      // Dark mode: light text works for all cells
      return Colors.white.withValues(alpha: intensity > 0.3 ? 1.0 : 0.7);
    } else {
      // Light mode: need to consider cell background color
      if (intensity <= 0) {
        // Empty cells have light gray background → dark text
        return Colors.black.withValues(alpha: 0.5);
      } else if (intensity < 0.6) {
        // Low/medium intensity cells have dark gradient colors → WHITE text
        return Colors.white;
      } else {
        // High intensity cells have bright colors → dark text
        return Colors.black.withValues(alpha: 0.8);
      }
    }
  }
}
