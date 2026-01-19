import 'package:flutter/foundation.dart';

import '../../../../core/constants/intensity_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/intensity_calculator.dart';
import '../entities/habit_entry.dart';

/// Data class to pass to isolate (must be top-level for compute())
class _IntensityCalculationParams {
  final List<Map<String, dynamic>> entriesData;
  final List<DateTime> targetDates;

  _IntensityCalculationParams(this.entriesData, this.targetDates);
}

/// Top-level function for isolate computation
Map<DateTime, double> _calculateIntensitiesIsolate(_IntensityCalculationParams params) {
  final targetDates = params.targetDates;
  final entriesData = params.entriesData;

  if (targetDates.isEmpty) return {};

  final results = <DateTime, double>{};

  // Rebuild entries from serialized data
  final entriesByDate = <DateTime, double>{};
  for (final data in entriesData) {
    final date = DateTime.fromMillisecondsSinceEpoch(data['date'] as int);
    final normalized = DateTime(date.year, date.month, date.day);
    entriesByDate[normalized] = data['value'] as double;
  }

  // Calculate global max for consistent fallback calculations
  final allNonZeroValues = entriesData
      .map((e) => e['value'] as double)
      .where((v) => v > 0)
      .toList();
  final globalMax = allNonZeroValues.isEmpty
      ? 0.0
      : allNonZeroValues.reduce((a, b) => a > b ? a : b);

  for (final targetDate in targetDates) {
    final normalized = DateTime(targetDate.year, targetDate.month, targetDate.day);
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
    for (final data in entriesData) {
      final entryDate = DateTime.fromMillisecondsSinceEpoch(data['date'] as int);
      final normalizedEntry = DateTime(entryDate.year, entryDate.month, entryDate.day);
      if (!normalizedEntry.isBefore(windowStart) &&
          !normalizedEntry.isAfter(windowEnd) &&
          (data['value'] as double) > 0) {
        windowValues.add(data['value'] as double);
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

/// Service for calculating heatmap intensities efficiently in batches.
abstract class IntensityService {
  /// Threshold for using isolate - only worth the overhead for large date ranges
  static const int _isolateThreshold = 60;

  /// Calculates intensities for a batch of dates.
  /// Uses isolate for large ranges (>60 days), synchronous for small ranges.
  static Future<Map<DateTime, double>> calculateBatchIntensitiesAsync({
    required List<HabitEntry> allEntries,
    required List<DateTime> targetDates,
  }) async {
    // For small date ranges, compute synchronously (isolate overhead not worth it)
    if (targetDates.length <= _isolateThreshold) {
      // ignore: deprecated_member_use_from_same_package
      return calculateBatchIntensities(
        allEntries: allEntries,
        targetDates: targetDates,
      );
    }

    // For large date ranges, use isolate to avoid blocking UI
    final entriesData = allEntries.map((e) => {
      'date': e.date.millisecondsSinceEpoch,
      'value': e.value,
    }).toList();

    return compute(
      _calculateIntensitiesIsolate,
      _IntensityCalculationParams(entriesData, targetDates),
    );
  }

  /// Calculates intensities for a batch of dates efficiently (sync version).
  @Deprecated('Use calculateBatchIntensitiesAsync for better performance')
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
