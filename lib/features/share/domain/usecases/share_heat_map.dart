import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../presentation/utils/heat_map_image_generator.dart';

/// Use case for sharing heat map images.
class ShareHeatMap {
  final HabitRepository _repository;

  ShareHeatMap(this._repository);

  /// Generates and shares a heat map image for the given habit and year.
  Future<void> call({
    required BuildContext context,
    required Habit habit,
    required int year,
  }) async {
    // Get entries for the year
    final entriesResult = await _repository.getEntriesInRange(
      habitId: habit.id,
      startDate: DateTime(year, 1, 1),
      endDate: DateTime(year, 12, 31),
    );

    final entries = entriesResult.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );

    // Generate image
    final filePath = await HeatMapImageGenerator.generate(
      context: context,
      habit: habit,
      entries: entries,
      year: year,
    );

    // Share
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'My ${habit.name} journey in $year \u{1F525}\n\nTracked with Ember',
    );
  }

  /// Gets entries for a specific year (for preview generation).
  Future<List<HabitEntry>> getEntriesForYear({
    required String habitId,
    required int year,
  }) async {
    final result = await _repository.getEntriesInRange(
      habitId: habitId,
      startDate: DateTime(year, 1, 1),
      endDate: DateTime(year, 12, 31),
    );

    return result.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );
  }

  /// Gets entries for a specific month (for monthly preview generation).
  Future<List<HabitEntry>> getEntriesForMonth({
    required String habitId,
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of month

    final result = await _repository.getEntriesInRange(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );
  }

  /// Gets all years that have data for a habit.
  Future<List<int>> getYearsWithData(String habitId) async {
    final result = await _repository.getEntriesForHabit(habitId);

    return result.fold(
      (failure) => <int>[],
      (entries) {
        final years = entries
            .map((e) => e.date.year)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
        return years;
      },
    );
  }

  /// Generates a preview image and returns the file path.
  Future<String> generatePreview({
    required BuildContext context,
    required Habit habit,
    required List<HabitEntry> entries,
    required int year,
  }) async {
    return HeatMapImageGenerator.generate(
      context: context,
      habit: habit,
      entries: entries,
      year: year,
    );
  }
}
