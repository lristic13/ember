import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../habits/presentation/viewmodels/habit_entries_viewmodel.dart';
import '../../../habits/presentation/viewmodels/habits_viewmodel.dart';
import '../../domain/entities/activity_insight.dart';
import '../../domain/entities/insights_period.dart';
import 'insights_state.dart';

part 'insights_viewmodel.g.dart';

@riverpod
class InsightsViewModel extends _$InsightsViewModel {
  InsightsPeriod _currentPeriod = InsightsPeriod.week;

  @override
  InsightsState build() {
    // Refresh when habits change — personal *or* shared.
    ref.watch(sortedHabitsProvider);

    _loadInsights(_currentPeriod);
    return const InsightsLoading();
  }

  Future<void> _loadInsights(InsightsPeriod period) async {
    _currentPeriod = period;
    final result = await _compute(period);
    state = InsightsLoaded(
      period: period,
      insights: result.insights,
      selectedInsight: null,
      allTimeTopName: result.topName,
      allTimeTopPercent: result.topPercent,
    );
  }

  Future<({List<ActivityInsight> insights, String? topName, int topPercent})>
  _compute(InsightsPeriod period) async {
    final habits = ref
        .read(sortedHabitsProvider)
        .where((h) => !h.isArchived)
        .toList();
    if (habits.isEmpty) {
      return (insights: const <ActivityInsight>[], topName: null, topPercent: 0);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDays = period.days;
    final periodStart = today.subtract(Duration(days: totalDays - 1));

    final insights = <ActivityInsight>[];
    String? topName;
    var topPercent = -1.0; // all-time best consistency, for the hero

    for (final habit in habits) {
      // Routes to Firestore for shared habits, Hive for personal ones.
      final entries = await ref.read(allHabitEntriesProvider(habit.id).future);

      var periodLogged = 0;
      var allTimeLogged = 0;
      DateTime? earliestLogged;
      entries.forEach((date, value) {
        final d = DateTime(date.year, date.month, date.day);
        if (value <= 0 || d.isAfter(today)) return; // ignore future backfills
        allTimeLogged++;
        if (earliestLogged == null || d.isBefore(earliestLogged!)) {
          earliestLogged = d;
        }
        if (!d.isBefore(periodStart)) periodLogged++;
      });

      insights.add(
        ActivityInsight(
          activity: habit,
          daysLogged: periodLogged,
          totalDays: totalDays,
          consistencyPercent: (periodLogged / totalDays) * 100,
          pieSharePercent: 0,
        ),
      );

      // All-time consistency = logged days / days tracked, where "tracked"
      // starts at the earliest of the habit's creation or its first log (past
      // dates can be backfilled, and shared habits carry an older history).
      final created = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      final start = (earliestLogged != null && earliestLogged!.isBefore(created))
          ? earliestLogged!
          : created;
      final span = today.difference(start).inDays + 1;
      final allTimeConsistency =
          (allTimeLogged / (span < 1 ? 1 : span) * 100).clamp(0, 100).toDouble();
      if (allTimeConsistency > topPercent) {
        topPercent = allTimeConsistency;
        topName = habit.name;
      }
    }

    final totalConsistency = insights.fold<double>(
      0,
      (sum, i) => sum + i.consistencyPercent,
    );
    final withShare = totalConsistency == 0
        ? insights
        : insights
              .map(
                (i) => i.copyWith(
                  pieSharePercent:
                      (i.consistencyPercent / totalConsistency) * 100,
                ),
              )
              .toList();
    withShare.sort(
      (a, b) => b.consistencyPercent.compareTo(a.consistencyPercent),
    );

    return (
      insights: withShare,
      topName: topName,
      topPercent: topPercent < 0 ? 0 : topPercent.round(),
    );
  }

  Future<void> setPeriod(InsightsPeriod period) async {
    state = const InsightsLoading();
    await _loadInsights(period);
  }

  void selectInsight(ActivityInsight? insight) {
    final current = state;
    if (current is! InsightsLoaded) return;

    final isSame = insight?.activity.id == current.selectedInsight?.activity.id;

    state = current.copyWith(
      selectedInsight: isSame ? null : insight,
      clearSelection: isSame,
    );
  }

  Future<void> refresh() async {
    final current = state;
    final period = current is InsightsLoaded
        ? current.period
        : InsightsPeriod.week;
    state = const InsightsLoading();
    await _loadInsights(period);
  }
}
