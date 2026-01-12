## Relevant Files

### New Files
- `lib/features/habits/presentation/screens/habit_details_screen.dart` - Main habit details page with stats and month heatmap
- `lib/features/habits/presentation/screens/year_heatmap_screen.dart` - Full year view with 12 mini-months
- `lib/features/habits/presentation/widgets/habit_statistics_card.dart` - Displays streak, total, average stats
- `lib/features/habits/presentation/widgets/statistic_item.dart` - Individual statistic display widget
- `lib/features/habits/presentation/widgets/month_heatmap.dart` - Calendar grid for single month
- `lib/features/habits/presentation/widgets/month_heatmap_cell.dart` - Day cell with day number
- `lib/features/habits/presentation/widgets/mini_month_heatmap.dart` - Compact month grid for year view
- `lib/features/habits/presentation/widgets/heatmap_tooltip.dart` - Popup showing date and value
- `lib/features/habits/presentation/widgets/heatmap_navigation.dart` - Month/year navigation arrows
- `lib/features/habits/presentation/viewmodels/habit_statistics_viewmodel.dart` - Calculate streaks, totals, averages
- `lib/features/habits/presentation/viewmodels/habit_statistics_state.dart` - State for statistics
- `lib/core/utils/statistics_calculator.dart` - Pure functions for streak/total/average calculations

### Modified Files
- `lib/core/router/app_router.dart` - Add habit details and year view routes
- `lib/core/constants/app_strings.dart` - Add strings for details page
- `lib/core/constants/app_dimensions.dart` - Add month/mini-month cell dimensions
- `lib/features/habits/presentation/widgets/habit_card.dart` - Change navigation to details page
- `lib/features/habits/presentation/viewmodels/habit_entries_viewmodel.dart` - Extend for month/year data

### Notes

- Follow Clean Architecture: domain → data → presentation layers
- One widget per file (per EMBER_INSTRUCTIONS.md)
- Use existing `AppColors.ember*` and `AppDimensions` constants
- Run `dart run build_runner build` after adding/modifying Riverpod providers
- Statistics calculations should be pure functions for testability

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [x] 1.0 Update routing and navigation structure
  - [x] 1.1 Add `habitDetails` route constant `/habits/:id` to `app_router.dart`
  - [x] 1.2 Add `yearHeatmap` route constant `/habits/:id/year` to `app_router.dart`
  - [x] 1.3 Add `habitDetailsPath(String id)` helper method
  - [x] 1.4 Add `yearHeatmapPath(String id)` helper method
  - [x] 1.5 Register `HabitDetailsScreen` route (to be created)
  - [x] 1.6 Register `YearHeatmapScreen` route (to be created)
  - [x] 1.7 Add new strings to `app_strings.dart` (habitDetails, viewYear, statistics labels, etc.)

- [x] 2.0 Create statistics calculation logic
  - [x] 2.1 Create `lib/core/utils/statistics_calculator.dart` with pure functions
  - [x] 2.2 Implement `calculateCurrentStreak(entries, dailyGoal)` - consecutive days ending today/yesterday
  - [x] 2.3 Implement `calculateLongestStreak(entries, dailyGoal)` - best consecutive days ever
  - [x] 2.4 Implement `calculateTotalLogged(entries)` - sum of all values
  - [x] 2.5 Implement `calculateDailyAverage(entries)` - average for days with entries
  - [x] 2.6 Create `habit_statistics_state.dart` with statistics data class
  - [x] 2.7 Create `habit_statistics_viewmodel.dart` using @riverpod with habitId parameter
  - [x] 2.8 Load all entries for habit and compute statistics in viewmodel
  - [x] 2.9 Run `dart run build_runner build`

- [x] 3.0 Build the Habit Details screen with header and statistics
  - [x] 3.1 Create `statistic_item.dart` widget showing label, value, and unit
  - [x] 3.2 Create `habit_statistics_card.dart` with 2x2 grid of StatisticItem widgets
  - [x] 3.3 Create `habit_details_screen.dart` with scaffold and app bar
  - [x] 3.4 Add Edit button to app bar that navigates to EditHabitScreen
  - [x] 3.5 Add header section with emoji, habit name, and daily goal
  - [x] 3.6 Integrate HabitStatisticsCard showing streak, total, average
  - [x] 3.7 Add placeholder for MonthHeatmap (to be built in Task 4)
  - [x] 3.8 Add "View Year" button below month heatmap placeholder

- [x] 4.0 Build the Month Heatmap component
  - [x] 4.1 Add month heatmap cell dimensions to `app_dimensions.dart`
  - [x] 4.2 Create `heatmap_navigation.dart` widget with left/right arrows and title
  - [x] 4.3 Create `month_heatmap_cell.dart` with day number, ember color, today indicator
  - [x] 4.4 Create `month_heatmap.dart` widget with calendar grid layout
  - [x] 4.5 Implement 7-column grid (Mon-Sun) with variable rows for weeks
  - [x] 4.6 Add day-of-week headers (M, T, W, T, F, S, S)
  - [x] 4.7 Handle cells outside current month (dim or hide)
  - [x] 4.8 Integrate HeatmapNavigation for month selection
  - [x] 4.9 Add state for selected month with navigation callbacks
  - [x] 4.10 Connect to habitEntriesViewModel to fetch month data
  - [x] 4.11 Integrate MonthHeatmap into HabitDetailsScreen

- [x] 5.0 Build the Year Heatmap screen
  - [x] 5.1 Add mini-month cell dimensions to `app_dimensions.dart`
  - [x] 5.2 Create `mini_month_heatmap.dart` - compact calendar grid (no day numbers)
  - [x] 5.3 Create `year_heatmap_screen.dart` with scaffold and app bar
  - [x] 5.4 Implement 4x3 or 3x4 grid of MiniMonthHeatmap widgets
  - [x] 5.5 Add month labels (Jan, Feb, etc.) above each mini-month
  - [x] 5.6 Integrate HeatmapNavigation for year selection
  - [x] 5.7 Add state for selected year with navigation callbacks
  - [x] 5.8 Load full year of entries and distribute to mini-months
  - [x] 5.9 Wire up navigation from HabitDetailsScreen "View Year" button

- [x] 6.0 Implement tooltip system for heatmap cells
  - [x] 6.1 Create tooltip using SnackBar (simpler approach)
  - [x] 6.2 Style tooltip with floating behavior
  - [x] 6.3 Show formatted date in tooltip
  - [x] 6.4 Auto-dismiss after 2 seconds
  - [x] 6.5 Integrate tooltip into `month_heatmap.dart` onCellTap
  - [x] 6.6 Integrate tooltip into `year_heatmap_screen.dart` cell onTap
  - [x] 6.7 Show "No entry" for cells with zero value

- [x] 7.0 Update HabitCard navigation and final integration
  - [x] 7.1 Update `habit_card.dart` to navigate to HabitDetailsScreen instead of EditHabitScreen
  - [x] 7.2 Keep week heatmap and quick-log on home screen habit cards
  - [x] 7.3 Run `flutter analyze` and fix any linter issues
  - [ ] 7.4 Test full navigation flow: Home → Details → Year → back (manual)
  - [ ] 7.5 Test month/year navigation arrows (manual)
  - [ ] 7.6 Test tooltip display on cell taps (manual)
  - [ ] 7.7 Test statistics accuracy (streak, total, average) (manual)
