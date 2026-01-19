import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/tracking_type.dart';
import '../viewmodels/habit_statistics_state.dart';
import 'statistic_item.dart';

class HabitStatisticsCard extends StatelessWidget {
  final HabitStatisticsState state;
  final String? unit;
  final Color? accentColor;
  final TrackingType? trackingType;

  const HabitStatisticsCard({
    super.key,
    required this.state,
    this.unit,
    this.accentColor,
    this.trackingType,
  });

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _formatStreak(int days) {
    return days.toString();
  }

  String _streakUnit(int days) {
    return days == 1 ? AppStrings.day : AppStrings.days;
  }

  @override
  Widget build(BuildContext context) {
    if (state is! HabitStatisticsLoaded) {
      return const SizedBox.shrink();
    }

    final stats = state as HabitStatisticsLoaded;
    final effectiveAccentColor = accentColor ?? Theme.of(context).colorScheme.primary;

    final showBestDay = trackingType == TrackingType.quantity &&
        stats.bestDay != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: StatisticItem(
                label: AppStrings.currentStreak,
                value: _formatStreak(stats.currentStreak),
                unit: _streakUnit(stats.currentStreak),
                valueColor: effectiveAccentColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            Expanded(
              child: StatisticItem(
                label: AppStrings.longestStreak,
                value: _formatStreak(stats.longestStreak),
                unit: _streakUnit(stats.longestStreak),
                valueColor: effectiveAccentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSm),
        Row(
          children: [
            Expanded(
              child: StatisticItem(
                label: AppStrings.totalLogged,
                value: _formatNumber(stats.totalLogged),
                unit: unit ?? '',
                valueColor: effectiveAccentColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            Expanded(
              child: StatisticItem(
                label: AppStrings.dailyAverage,
                value: _formatNumber(stats.dailyAverage),
                unit: unit ?? '',
                valueColor: effectiveAccentColor,
              ),
            ),
          ],
        ),
        if (showBestDay) ...[
          const SizedBox(height: AppDimensions.paddingSm),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: StatisticItem(
                label: AppStrings.bestDay,
                value: stats.bestDay!,
                valueColor: effectiveAccentColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
