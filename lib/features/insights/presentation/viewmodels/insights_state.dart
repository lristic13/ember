import '../../domain/entities/activity_insight.dart';
import '../../domain/entities/insights_period.dart';

sealed class InsightsState {
  const InsightsState();
}

class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

class InsightsError extends InsightsState {
  final String message;
  const InsightsError(this.message);
}

class InsightsLoaded extends InsightsState {
  final InsightsPeriod period;
  final List<ActivityInsight> insights;
  final ActivityInsight? selectedInsight;

  /// The habit shown up for most consistently across **all time** (for the
  /// hero banner — independent of the selected [period]).
  final String? allTimeTopName;
  final int allTimeTopPercent;

  const InsightsLoaded({
    required this.period,
    required this.insights,
    this.selectedInsight,
    this.allTimeTopName,
    this.allTimeTopPercent = 0,
  });

  InsightsLoaded copyWith({
    InsightsPeriod? period,
    List<ActivityInsight>? insights,
    ActivityInsight? selectedInsight,
    String? allTimeTopName,
    int? allTimeTopPercent,
    bool clearSelection = false,
  }) {
    return InsightsLoaded(
      period: period ?? this.period,
      insights: insights ?? this.insights,
      selectedInsight: clearSelection ? null : (selectedInsight ?? this.selectedInsight),
      allTimeTopName: allTimeTopName ?? this.allTimeTopName,
      allTimeTopPercent: allTimeTopPercent ?? this.allTimeTopPercent,
    );
  }
}
