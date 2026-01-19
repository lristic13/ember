import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../../../core/utils/statistics_calculator.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';

/// Statistics section for the share card.
/// Displays key stats: days logged, streak, total, average, best day.
class ShareCardStats extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final int year;
  final int? month;
  final HabitGradient gradient;

  const ShareCardStats({
    super.key,
    required this.habit,
    required this.entries,
    required this.year,
    this.month,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    // Build list of stats to show
    final statItems = <_StatData>[
      _StatData(
        icon: Icons.calendar_today,
        label: 'Days Logged',
        value: stats.daysLogged.toString(),
      ),
      _StatData(
        icon: Icons.local_fire_department,
        label: 'Longest Streak',
        value: '${stats.longestStreak} days',
      ),
    ];

    // Add quantity-specific stats
    if (habit.isQuantity) {
      statItems.add(
        _StatData(
          icon: Icons.bar_chart,
          label: 'Total',
          value: _formatValue(stats.totalValue),
        ),
      );
      statItems.add(
        _StatData(
          icon: Icons.trending_up,
          label: 'Daily Average',
          value: _formatValue(stats.dailyAverage),
        ),
      );
    }

    // Add best day of week (by average)
    if (stats.bestDay != null) {
      statItems.add(
        _StatData(
          icon: Icons.emoji_events,
          label: 'Best Day',
          value: stats.bestDay!,
        ),
      );
    }

    // Layout: 2 columns for first 4 stats, then full width for best day
    return Column(
      children: [
        // First row: Days logged & Longest streak
        Row(
          children: [
            Expanded(child: _buildStatCard(statItems[0])),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(statItems[1])),
          ],
        ),
        if (habit.isQuantity) ...[
          const SizedBox(height: 16),
          // Second row: Total & Daily average
          Row(
            children: [
              Expanded(child: _buildStatCard(statItems[2])),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(statItems[3])),
            ],
          ),
        ],
        if (stats.bestDay != null) ...[
          const SizedBox(height: 16),
          // Best day - full width
          _buildStatCard(statItems.last, fullWidth: true),
        ],
      ],
    );
  }

  Widget _buildStatCard(_StatData stat, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        color: gradient.max.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.max.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: fullWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: gradient.max.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: gradient.max, size: 40),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: TextStyle(
                    color: gradient.max,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatsResult _calculateStats() {
    if (entries.isEmpty) {
      return _StatsResult(
        daysLogged: 0,
        longestStreak: 0,
        totalValue: 0,
        dailyAverage: 0,
        bestDay: null,
      );
    }

    // Filter entries with value > 0
    final validEntries = entries.where((e) => e.value > 0).toList();

    // Days logged
    final uniqueDays = validEntries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    final daysLogged = uniqueDays.length;

    // Longest streak
    final sortedDates = uniqueDays.toList()..sort();
    int longestStreak = sortedDates.isEmpty ? 0 : 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) longestStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    // Total value
    final totalValue = validEntries.fold<double>(0, (sum, e) => sum + e.value);

    // Daily average
    final dailyAverage = daysLogged > 0 ? totalValue / daysLogged : 0.0;

    // Best day of week (by average) - use shared calculator
    final bestDay = StatisticsCalculator.calculateBestDay(validEntries);

    return _StatsResult(
      daysLogged: daysLogged,
      longestStreak: longestStreak,
      totalValue: totalValue,
      dailyAverage: dailyAverage,
      bestDay: bestDay,
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return '${value.round()}${habit.unit != null ? ' ${habit.unit}' : ''}';
    }
    return '${value.toStringAsFixed(1)}${habit.unit != null ? ' ${habit.unit}' : ''}';
  }

}

class _StatData {
  final IconData icon;
  final String label;
  final String value;

  _StatData({required this.icon, required this.label, required this.value});
}

class _StatsResult {
  final int daysLogged;
  final int longestStreak;
  final double totalValue;
  final double dailyAverage;
  final String? bestDay;

  _StatsResult({
    required this.daysLogged,
    required this.longestStreak,
    required this.totalValue,
    required this.dailyAverage,
    required this.bestDay,
  });
}
