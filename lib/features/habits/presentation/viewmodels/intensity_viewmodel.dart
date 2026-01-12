import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/intensity_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/services/intensity_service.dart';
import 'habits_providers.dart';

part 'intensity_viewmodel.g.dart';

/// Provider that calculates batch intensities for a date range.
@riverpod
Future<Map<DateTime, double>> habitIntensities(
  Ref ref,
  String habitId, {
  required DateTime startDate,
  required DateTime endDate,
}) async {
  // Expand range to include 60-day window for earliest date
  final expandedStart = startDate.subtract(
    const Duration(days: IntensityConfig.rollingWindowDays),
  );

  final getHabitEntries = ref.read(getHabitEntriesUseCaseProvider);
  final result = await getHabitEntries.inRange(
    habitId: habitId,
    startDate: expandedStart,
    endDate: endDate,
  );

  return result.fold(
    (failure) => <DateTime, double>{},
    (entries) {
      // Generate list of target dates
      final targetDates = <DateTime>[];
      var current = DateUtils.dateOnly(startDate);
      final normalizedEnd = DateUtils.dateOnly(endDate);
      while (!current.isAfter(normalizedEnd)) {
        targetDates.add(current);
        current = current.add(const Duration(days: 1));
      }

      return IntensityService.calculateBatchIntensities(
        allEntries: entries,
        targetDates: targetDates,
      );
    },
  );
}
