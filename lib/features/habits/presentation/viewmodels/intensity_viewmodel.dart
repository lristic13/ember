import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/intensity_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/services/intensity_service.dart';
import 'habits_providers.dart';
import 'shared_habit_providers.dart';

part 'intensity_viewmodel.g.dart';

/// Provider that calculates batch intensities for a date range.
/// Uses keepAlive to cache results when switching between years.
@Riverpod(keepAlive: true)
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

  final isShared = ref.watch(
    sharedHabitsProvider.select(
      (async) => async.asData?.value.any((h) => h.id == habitId) ?? false,
    ),
  );

  final List<HabitEntry> entries;
  if (isShared) {
    // Shared habit: build entries from the Firestore stream so intensity is
    // computed over the shared history (same glow for every participant).
    final map = await ref.watch(sharedHabitEntriesProvider(habitId).future);
    entries = [
      for (final entry in map.entries)
        if (!entry.key.isBefore(expandedStart) && !entry.key.isAfter(endDate))
          HabitEntry(
            id: '$habitId|${entry.key.toIso8601String()}',
            habitId: habitId,
            date: entry.key,
            value: entry.value,
          ),
    ];
  } else {
    final getHabitEntries = ref.read(getHabitEntriesUseCaseProvider);
    final result = await getHabitEntries.inRange(
      habitId: habitId,
      startDate: expandedStart,
      endDate: endDate,
    );
    if (result.isFailure) return <DateTime, double>{};
    entries = result.valueOrNull ?? [];
  }

  // Generate list of target dates
  final targetDates = <DateTime>[];
  var current = DateUtils.dateOnly(startDate);
  final normalizedEnd = DateUtils.dateOnly(endDate);
  while (!current.isAfter(normalizedEnd)) {
    targetDates.add(current);
    current = current.add(const Duration(days: 1));
  }

  return IntensityService.calculateBatchIntensitiesAsync(
    allEntries: entries,
    targetDates: targetDates,
  );
}
