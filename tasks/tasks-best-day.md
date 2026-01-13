# Tasks: Best Day Statistic

## Relevant Files

- `lib/core/utils/statistics_calculator.dart` - Add `calculateBestDay` method to compute best performing weekday
- `lib/features/habits/presentation/viewmodels/habit_statistics_state.dart` - Add `bestDay` field to `HabitStatisticsLoaded`
- `lib/features/habits/presentation/viewmodels/habit_statistics_viewmodel.dart` - Calculate and include best day in state
- `lib/features/habits/presentation/widgets/habit_statistics_card.dart` - Display best day row for quantity types
- `lib/core/constants/app_strings.dart` - Add "Best Day" label string

### Notes

- This feature only applies to quantity/measured tracking types
- Completion-type activities should not display the best day statistic
- Day names should be in English (Monday, Tuesday, etc.)
- If multiple days tie for highest average, use the earliest weekday (Monday first)

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [x] 1.0 Add best day calculation logic to StatisticsCalculator
  - [x] 1.1 Read `lib/core/utils/statistics_calculator.dart` to understand existing patterns
  - [x] 1.2 Add `calculateBestDay(List<HabitEntry> entries)` static method that returns `String?`
  - [x] 1.3 Group entries by weekday (using `DateTime.weekday`: 1=Monday, 7=Sunday)
  - [x] 1.4 Calculate average value for each weekday
  - [x] 1.5 Return the weekday name with highest average (or `null` if no entries)
  - [x] 1.6 Handle ties by returning earliest weekday (lower weekday number wins)

- [x] 2.0 Update HabitStatisticsState to include best day field
  - [x] 2.1 Read `lib/features/habits/presentation/viewmodels/habit_statistics_state.dart`
  - [x] 2.2 Add `String? bestDay` field to `HabitStatisticsLoaded` class
  - [x] 2.3 Update constructor to include `this.bestDay` parameter

- [x] 3.0 Update HabitStatisticsViewModel to calculate and provide best day
  - [x] 3.1 Read `lib/features/habits/presentation/viewmodels/habit_statistics_viewmodel.dart`
  - [x] 3.2 Call `StatisticsCalculator.calculateBestDay(entries)` in `_loadStatistics()`
  - [x] 3.3 Pass the result to `HabitStatisticsLoaded` constructor

- [x] 4.0 Update HabitStatisticsCard to display best day row for quantity types
  - [x] 4.1 Read `lib/features/habits/presentation/widgets/habit_statistics_card.dart`
  - [x] 4.2 Add `TrackingType? trackingType` parameter to `HabitStatisticsCard`
  - [x] 4.3 Add "Best Day" string constant to `lib/core/constants/app_strings.dart`
  - [x] 4.4 Add a new row below the existing 2x2 grid with a centered `StatisticItem`
  - [x] 4.5 Conditionally render best day row only when `trackingType == TrackingType.quantity` and `bestDay != null`
  - [x] 4.6 Update `HabitDetailsContent` to pass `trackingType` to `HabitStatisticsCard`
