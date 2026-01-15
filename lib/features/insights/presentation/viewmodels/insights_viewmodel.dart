import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../habits/presentation/viewmodels/habits_viewmodel.dart';
import '../../domain/entities/activity_insight.dart';
import '../../domain/entities/insights_period.dart';
import 'insights_providers.dart';
import 'insights_state.dart';

part 'insights_viewmodel.g.dart';

@riverpod
class InsightsViewModel extends _$InsightsViewModel {
  InsightsPeriod _currentPeriod = InsightsPeriod.week;

  @override
  InsightsState build() {
    // Watch habits to refresh when they change
    ref.watch(habitsViewModelProvider);

    _loadInsights(_currentPeriod);
    return const InsightsLoading();
  }

  Future<void> _loadInsights(InsightsPeriod period) async {
    _currentPeriod = period;
    final getInsights = ref.read(getActivityInsightsProvider);
    final insights = await getInsights(period: period);

    state = InsightsLoaded(
      period: period,
      insights: insights,
      selectedInsight: null,
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
