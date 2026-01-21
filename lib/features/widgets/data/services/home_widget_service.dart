import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/utils/statistics_calculator.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../domain/entities/widget_activity_data.dart';

/// Service for managing home screen widgets.
/// Handles data synchronization between Flutter and native widgets.
class HomeWidgetService {
  final HabitRepository _habitRepository;

  /// iOS App Group identifier - must match the App Group configured in Xcode
  static const String appGroupId = 'group.com.lristic.ember';

  /// iOS widget name - must match the widget extension name
  static const String iOSWidgetName = 'EmberWidget';

  /// Android widget receiver name
  static const String androidWidgetName = 'EmberWidgetReceiver';

  /// Callback for handling navigation when widget is clicked
  void Function(String habitId)? onOpenActivity;

  HomeWidgetService({
    required HabitRepository habitRepository,
  }) : _habitRepository = habitRepository;

  /// Initialize home widget functionality.
  /// Must be called before any other widget operations.
  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);

    // Register callback for when widget is tapped
    HomeWidget.widgetClicked.listen(_handleWidgetClick);

    // Sync any pending widget logs to the database
    await _syncPendingWidgetLogs();
  }

  /// Sync pending widget logs from UserDefaults to the database.
  /// This handles logs made via the widget's quick-log button.
  /// Call this when app comes to foreground.
  /// Returns true if there were pending logs that were synced.
  Future<bool> syncPendingWidgetLogs() async {
    return await _syncPendingWidgetLogs();
  }

  Future<bool> _syncPendingWidgetLogs() async {
    final pendingLogsJson = await HomeWidget.getWidgetData<String>('pending_widget_logs');
    if (pendingLogsJson == null) return false;

    try {
      final pendingLogs = jsonDecode(pendingLogsJson) as List<dynamic>?;
      if (pendingLogs == null || pendingLogs.isEmpty) return false;

      for (final log in pendingLogs) {
        final habitId = log['habitId'] as String?;
        final value = (log['value'] as num?)?.toDouble();

        if (habitId != null && value != null) {
          final today = app_date_utils.DateUtils.dateOnly(DateTime.now());
          await _habitRepository.logEntry(
            habitId: habitId,
            date: today,
            value: value,
          );
        }
      }

      // Clear pending logs after syncing
      await HomeWidget.saveWidgetData('pending_widget_logs', null);
      return true;
    } catch (e) {
      // Ignore parsing errors, just clear the pending logs
      await HomeWidget.saveWidgetData('pending_widget_logs', null);
      return false;
    }
  }

  /// Check for initial widget click URI when app launches.
  /// Returns the URI if the app was launched from a widget click.
  Future<Uri?> getInitialUri() async {
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  /// Update widget data for a specific habit.
  Future<void> updateActivityWidget(String habitId) async {
    final habitResult = await _habitRepository.getHabitById(habitId);

    await habitResult.fold(
      (failure) async {
        // Habit not found, clear widget data for this activity
        await HomeWidget.saveWidgetData('activity_$habitId', null);
        await _refreshWidgets();
      },
      (habit) async {
        if (habit.isArchived) {
          // Don't show archived habits in widgets
          await HomeWidget.saveWidgetData('activity_$habitId', null);
        } else {
          final widgetData = await _buildWidgetData(habit);
          await HomeWidget.saveWidgetData(
            'activity_$habitId',
            jsonEncode(widgetData.toJson()),
          );
        }
        await _refreshWidgets();
      },
    );
  }

  /// Update all activity widgets.
  /// Also saves the list of available activities for widget configuration.
  Future<void> updateAllWidgets() async {
    final habitsResult = await _habitRepository.getHabits(includeArchived: false);

    await habitsResult.fold(
      (failure) async {
        // On failure, just refresh widgets with existing data
        await _refreshWidgets();
      },
      (habits) async {
        // Save data for each habit
        for (final habit in habits) {
          final widgetData = await _buildWidgetData(habit);
          await HomeWidget.saveWidgetData(
            'activity_${habit.id}',
            jsonEncode(widgetData.toJson()),
          );
        }

        // Save list of available activities for widget configuration
        final activityList = habits
            .map((h) => {
                  'id': h.id,
                  'name': h.name,
                  'emoji': h.emoji,
                })
            .toList();

        await HomeWidget.saveWidgetData(
          'available_activities',
          jsonEncode(activityList),
        );

        await _refreshWidgets();
      },
    );
  }

  /// Build widget data for a habit.
  Future<WidgetActivityData> _buildWidgetData(Habit habit) async {
    final now = DateTime.now();
    final today = app_date_utils.DateUtils.dateOnly(now);

    // Get current week's dates (Monday to Sunday)
    final weekDates = app_date_utils.DateUtils.getWeekDates(now);
    final monday = weekDates.first;
    final sunday = weekDates.last;

    // Get entries for the week
    final weekEntriesResult = await _habitRepository.getEntriesInRange(
      habitId: habit.id,
      startDate: monday,
      endDate: sunday,
    );

    final weekEntries = weekEntriesResult.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );

    // Build week values array (Mon-Sun)
    final weekValues = _calculateCurrentWeekValues(weekDates, weekEntries);

    // Get today's value
    final todayValue = _getTodayValue(today, weekEntries);

    // Get all entries for streak calculation
    final allEntriesResult = await _habitRepository.getEntriesForHabit(habit.id);
    final allEntries = allEntriesResult.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );

    // Calculate current streak
    final currentStreak = StatisticsCalculator.calculateCurrentStreak(allEntries);

    return WidgetActivityData(
      id: habit.id,
      name: habit.name,
      emoji: habit.emoji,
      isCompletion: habit.isCompletion,
      unit: habit.unit,
      todayValue: todayValue,
      currentStreak: currentStreak,
      weekValues: weekValues,
      gradientId: habit.gradientId,
    );
  }

  /// Calculate week values (Mon-Sun) from entries.
  List<double> _calculateCurrentWeekValues(
    List<DateTime> weekDates,
    List<HabitEntry> entries,
  ) {
    final weekValues = List<double>.filled(7, 0.0);

    for (final entry in entries) {
      final entryDate = app_date_utils.DateUtils.dateOnly(entry.date);

      for (int i = 0; i < weekDates.length; i++) {
        if (app_date_utils.DateUtils.isSameDay(entryDate, weekDates[i])) {
          weekValues[i] += entry.value;
          break;
        }
      }
    }

    return weekValues;
  }

  /// Get today's value from entries.
  double _getTodayValue(DateTime today, List<HabitEntry> entries) {
    double todayValue = 0.0;

    for (final entry in entries) {
      if (app_date_utils.DateUtils.isSameDay(entry.date, today)) {
        todayValue += entry.value;
      }
    }

    return todayValue;
  }

  /// Refresh all native widgets.
  Future<void> _refreshWidgets() async {
    await HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }

  /// Handle widget click callback.
  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    final action = uri.host;
    final habitId = uri.queryParameters['habitId'];

    if (habitId == null) return;

    switch (action) {
      case 'log':
        _handleQuickLog(habitId);
        break;
      case 'open':
        _handleOpenActivity(habitId);
        break;
    }
  }

  /// Handle quick log from widget (+1 or toggle).
  Future<void> _handleQuickLog(String habitId) async {
    final habitResult = await _habitRepository.getHabitById(habitId);

    await habitResult.fold(
      (failure) async {
        // Habit not found, nothing to do
      },
      (habit) async {
        final now = DateTime.now();
        final today = app_date_utils.DateUtils.dateOnly(now);

        // Get existing entry for today
        final existingEntryResult = await _habitRepository.getEntryForDate(
          habitId: habitId,
          date: today,
        );

        final existingEntry = existingEntryResult.fold(
          (failure) => null,
          (entry) => entry,
        );

        final double newValue;
        if (habit.isCompletion) {
          // Toggle completion
          newValue = (existingEntry?.value ?? 0) > 0 ? 0.0 : 1.0;
        } else {
          // Add +1 to quantity
          newValue = (existingEntry?.value ?? 0) + 1;
        }

        // Log the entry
        await _habitRepository.logEntry(
          habitId: habitId,
          date: today,
          value: newValue,
        );

        // Update widget to reflect change
        await updateActivityWidget(habitId);
      },
    );
  }

  /// Handle opening activity in app.
  void _handleOpenActivity(String habitId) {
    onOpenActivity?.call(habitId);
  }
}
