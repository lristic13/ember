# Ember - Activity Insights Feature

## Overview

A new "Insights" screen that shows users how their effort is distributed across activities. The centerpiece is a pie chart displaying consistency percentages, answering: "Of my total effort, where does it go?"

This feature gives users a reason to open the app beyond just logging—they can see patterns and understand their own behavior.

---

## Core Concept

**Consistency** = Days with entry ÷ Total days in period

Example for last 30 days:
- Workout: logged 12 days → 40% consistency
- Water: logged 24 days → 80% consistency
- Reading: logged 18 days → 60% consistency

**Pie chart** shows relative distribution (normalized):
- Workout: 40/180 = 22% of pie
- Water: 80/180 = 44% of pie
- Reading: 60/180 = 33% of pie

---

## Package

Use `fl_chart` for the pie chart:

```yaml
dependencies:
  fl_chart: ^0.69.0
```

---

## Data Models

### ActivityInsight Entity

```dart
class ActivityInsight {
  final Activity activity;
  final int daysLogged;
  final int totalDays;
  final double consistencyPercent; // 0-100
  final double pieSharePercent;    // 0-100, normalized across all activities

  const ActivityInsight({
    required this.activity,
    required this.daysLogged,
    required this.totalDays,
    required this.consistencyPercent,
    required this.pieSharePercent,
  });
}
```

### InsightsPeriod Enum

```dart
enum InsightsPeriod {
  week(7, 'Last 7 days'),
  month(30, 'Last 30 days'),
  quarter(90, 'Last 90 days'),
  allTime(null, 'All time');

  final int? days;
  final String label;

  const InsightsPeriod(this.days, this.label);
}
```

---

## Calculation Logic

### UseCase: GetActivityInsights

```dart
class GetActivityInsights {
  final ActivityRepository _activityRepository;
  final EntryRepository _entryRepository;

  GetActivityInsights(this._activityRepository, this._entryRepository);

  Future<List<ActivityInsight>> call({required InsightsPeriod period}) async {
    final activities = await _activityRepository.getAll();
    if (activities.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final insights = <ActivityInsight>[];

    for (final activity in activities) {
      if (activity.isArchived) continue;

      // Calculate period boundaries
      final activityCreatedDate = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );

      final int totalDays;
      final DateTime periodStart;

      if (period.days == null) {
        // All time: from creation to today
        totalDays = today.difference(activityCreatedDate).inDays + 1;
        periodStart = activityCreatedDate;
      } else {
        // Fixed period: use the smaller of period or days since creation
        final daysSinceCreated = today.difference(activityCreatedDate).inDays + 1;
        totalDays = min(period.days!, daysSinceCreated);
        periodStart = today.subtract(Duration(days: totalDays - 1));
      }

      if (totalDays <= 0) continue;

      // Get entries in period
      final entries = await _entryRepository.getEntriesInRange(
        activityId: activity.id,
        start: periodStart,
        end: today,
      );

      // Count unique days with positive entries
      final uniqueDaysLogged = entries
          .where((e) => e.value > 0)
          .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
          .toSet()
          .length;

      final consistencyPercent = (uniqueDaysLogged / totalDays) * 100;

      insights.add(ActivityInsight(
        activity: activity,
        daysLogged: uniqueDaysLogged,
        totalDays: totalDays,
        consistencyPercent: consistencyPercent,
        pieSharePercent: 0, // Calculated below
      ));
    }

    // Calculate pie share (normalized)
    final totalConsistency = insights.fold<double>(
      0,
      (sum, i) => sum + i.consistencyPercent,
    );

    if (totalConsistency == 0) return insights;

    return insights.map((insight) {
      return ActivityInsight(
        activity: insight.activity,
        daysLogged: insight.daysLogged,
        totalDays: insight.totalDays,
        consistencyPercent: insight.consistencyPercent,
        pieSharePercent: (insight.consistencyPercent / totalConsistency) * 100,
      );
    }).toList()
      ..sort((a, b) => b.consistencyPercent.compareTo(a.consistencyPercent));
  }
}
```

---

## UI Components

### Screen Layout

```
┌─────────────────────────────────┐
│ ← Insights                      │
│                                 │
│  ┌─────────────────────────┐    │
│  │ Last 30 days        ▼  │    │  ← Period selector dropdown
│  └─────────────────────────┘    │
│                                 │
│         ╭─────────────╮         │
│       ╱    ╭─────╮     ╲        │
│      │   ╱  44%  ╲   │       │
│      │  │  Water  │  │       │  ← Pie chart with center label
│      │   ╲       ╱   │       │
│       ╲    ╰─────╯     ╱        │
│         ╰─────────────╯         │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  💧 Water                       │
│  ████████████████░░░░  80%      │  ← Consistency bar
│  24 of 30 days                  │
│                                 │
│  🏋️ Workout                     │
│  ████████████░░░░░░░░  60%      │
│  18 of 30 days                  │
│                                 │
│  📚 Reading                     │
│  ████████░░░░░░░░░░░░  40%      │
│  12 of 30 days                  │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  💡 You're most consistent      │
│     with Water!                 │
│                                 │
└─────────────────────────────────┘
```

### File Structure

```
lib/features/insights/
├── domain/
│   ├── entities/
│   │   ├── activity_insight.dart
│   │   └── insights_period.dart
│   └── usecases/
│       └── get_activity_insights.dart
└── presentation/
    ├── viewmodels/
    │   └── insights_viewmodel.dart
    ├── screens/
    │   └── insights_screen.dart
    └── widgets/
        ├── period_selector.dart
        ├── insights_pie_chart.dart
        ├── activity_consistency_list.dart
        ├── activity_consistency_item.dart
        └── insights_tip_card.dart
```

---

## Widget Implementations

### Pie Chart Widget

```dart
class InsightsPieChart extends ConsumerWidget {
  final List<ActivityInsight> insights;
  final ActivityInsight? selectedInsight;
  final ValueChanged<ActivityInsight?>? onSectionTap;

  const InsightsPieChart({
    super.key,
    required this.insights,
    this.selectedInsight,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sections: insights.map((insight) {
            final isSelected = selectedInsight?.activity.id == insight.activity.id;
            final gradient = HabitGradientPresets.getById(insight.activity.gradientId);

            return PieChartSectionData(
              value: insight.pieSharePercent,
              title: '${insight.pieSharePercent.round()}%',
              titleStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isSelected ? 16 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              color: gradient.max,
              radius: isSelected ? 110 : 100,
              titlePositionPercentageOffset: 0.55,
            );
          }).toList(),
          centerSpaceRadius: 60,
          sectionsSpace: 2,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response?.touchedSection != null) {
                final index = response!.touchedSection!.touchedSectionIndex;
                if (index >= 0 && index < insights.length) {
                  onSectionTap?.call(insights[index]);
                }
              }
            },
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}
```

### Consistency Bar Item

```dart
class ActivityConsistencyItem extends StatelessWidget {
  final ActivityInsight insight;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const ActivityConsistencyItem({
    super.key,
    required this.insight,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = HabitGradientPresets.getById(insight.activity.gradientId);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isHighlighted
              ? gradient.max.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: isHighlighted
              ? Border.all(color: gradient.max, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity name row
            Row(
              children: [
                Text(
                  insight.activity.emoji ?? '🔥',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    insight.activity.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${insight.consistencyPercent.round()}%',
                  style: TextStyle(
                    color: gradient.max,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacingSmall),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              child: LinearProgressIndicator(
                value: insight.consistencyPercent / 100,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation(gradient.max),
                minHeight: 8,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXSmall),

            // Days logged
            Text(
              '${insight.daysLogged} of ${insight.totalDays} days',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Tip Card

```dart
class InsightsTipCard extends StatelessWidget {
  final List<ActivityInsight> insights;

  const InsightsTipCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final top = insights.first;
    final gradient = HabitGradientPresets.getById(top.activity.gradientId);

    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: gradient.max.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: gradient.max.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 24)),
          SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "You're most consistent with ",
                style: TextStyle(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: top.activity.name,
                    style: TextStyle(
                      color: gradient.max,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: '!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ViewModel

```dart
@riverpod
class InsightsViewModel extends _$InsightsViewModel {
  @override
  Future<InsightsState> build() async {
    return _loadInsights(InsightsPeriod.month);
  }

  Future<InsightsState> _loadInsights(InsightsPeriod period) async {
    final insights = await ref.read(getActivityInsightsProvider).call(
      period: period,
    );

    return InsightsState(
      period: period,
      insights: insights,
      selectedInsight: null,
    );
  }

  Future<void> setPeriod(InsightsPeriod period) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadInsights(period));
  }

  void selectInsight(ActivityInsight? insight) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      selectedInsight: insight?.activity.id == current.selectedInsight?.activity.id
          ? null  // Toggle off if same
          : insight,
    ));
  }
}

class InsightsState {
  final InsightsPeriod period;
  final List<ActivityInsight> insights;
  final ActivityInsight? selectedInsight;

  const InsightsState({
    required this.period,
    required this.insights,
    this.selectedInsight,
  });

  InsightsState copyWith({
    InsightsPeriod? period,
    List<ActivityInsight>? insights,
    ActivityInsight? selectedInsight,
  }) {
    return InsightsState(
      period: period ?? this.period,
      insights: insights ?? this.insights,
      selectedInsight: selectedInsight,
    );
  }
}
```

---

## Empty State

When no activities exist or no entries logged:

```dart
class InsightsEmptyState extends StatelessWidget {
  const InsightsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📊', style: TextStyle(fontSize: 64)),
          SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'No insights yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Start logging activities to see\nyour consistency breakdown',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
```

---

## Navigation

Add route to GoRouter:

```dart
GoRoute(
  path: '/insights',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const InsightsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
),
```

Add entry point from home screen (e.g., icon button in app bar or a card).

---

## Animations

1. **Pie chart** — fl_chart has built-in animation when data changes
2. **List items** — Stagger fade-in when screen loads
3. **Selection** — AnimatedContainer for highlight state
4. **Period change** — Fade transition when switching periods

---

## Summary

| Component | Purpose |
|-----------|---------|
| `ActivityInsight` | Data model holding consistency stats |
| `InsightsPeriod` | Enum for time period selection |
| `GetActivityInsights` | UseCase calculating all stats |
| `InsightsPieChart` | Pie chart showing relative distribution |
| `ActivityConsistencyItem` | List item with progress bar |
| `InsightsTipCard` | Motivational tip highlighting top activity |
| `InsightsViewModel` | State management with period/selection |

This gives users a compelling reason to return—seeing their own patterns is addictive.
