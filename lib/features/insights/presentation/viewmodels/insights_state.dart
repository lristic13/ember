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

  const InsightsLoaded({
    required this.period,
    required this.insights,
    this.selectedInsight,
  });

  InsightsLoaded copyWith({
    InsightsPeriod? period,
    List<ActivityInsight>? insights,
    ActivityInsight? selectedInsight,
    bool clearSelection = false,
  }) {
    return InsightsLoaded(
      period: period ?? this.period,
      insights: insights ?? this.insights,
      selectedInsight: clearSelection ? null : (selectedInsight ?? this.selectedInsight),
    );
  }
}
