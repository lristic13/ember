import '../../../../core/constants/intensity_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/intensity_calculator.dart';
import '../entities/habit_entry.dart';

/// Service for calculating heatmap intensities efficiently in batches.
abstract class IntensityService {
  /// Calculates intensities for a batch of dates efficiently.
  ///
  /// Algorithm:
  /// 1. Build a map of date -> value for O(1) lookup
  /// 2. Calculate global max for fallback method (consistent across all cells)
  /// 3. For each target date, gather the 60-day window and calculate intensity
  static Map<DateTime, double> calculateBatchIntensities({
    required List<HabitEntry> allEntries,
    required List<DateTime> targetDates,
  }) {
    if (targetDates.isEmpty) return {};

    final results = <DateTime, double>{};

    // Build a map of date -> value for O(1) lookup
    final entriesByDate = <DateTime, double>{};
    for (final entry in allEntries) {
      final normalized = DateUtils.dateOnly(entry.date);
      entriesByDate[normalized] = entry.value;
    }

    // Calculate global max for consistent fallback calculations
    final allNonZeroValues =
        allEntries.map((e) => e.value).where((v) => v > 0).toList();
    final globalMax = allNonZeroValues.isEmpty
        ? 0.0
        : allNonZeroValues.reduce((a, b) => a > b ? a : b);

    for (final targetDate in targetDates) {
      final normalized = DateUtils.dateOnly(targetDate);
      final todayValue = entriesByDate[normalized] ?? 0;

      if (todayValue <= 0) {
        results[normalized] = 0.0;
        continue;
      }

      // Gather 60-day window BEFORE targetDate (not including targetDate itself)
      final windowStart = normalized.subtract(
        const Duration(days: IntensityConfig.rollingWindowDays),
      );
      final windowEnd = normalized.subtract(const Duration(days: 1));

      final windowValues = <double>[];
      for (final entry in allEntries) {
        final entryDate = DateUtils.dateOnly(entry.date);
        if (!entryDate.isBefore(windowStart) &&
            !entryDate.isAfter(windowEnd) &&
            entry.value > 0) {
          windowValues.add(entry.value);
        }
      }

      results[normalized] = IntensityCalculator.calculateIntensity(
        todayValue: todayValue,
        historicalValues: windowValues,
        globalMax: globalMax,
      );
    }

    return results;
  }
}
