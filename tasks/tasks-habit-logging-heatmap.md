## Relevant Files

- `lib/features/habits/presentation/viewmodels/habit_entries_viewmodel.dart` - ViewModel for managing habit entries state per habit
- `lib/features/habits/presentation/viewmodels/habit_entries_state.dart` - State class for habit entries (loading, loaded, error)
- `lib/features/habits/presentation/viewmodels/habits_providers.dart` - Add new providers for entries
- `lib/features/habits/presentation/widgets/week_heatmap.dart` - Main week heatmap widget (7-day row)
- `lib/features/habits/presentation/widgets/heatmap_cell.dart` - Individual day cell widget with ember colors
- `lib/features/habits/presentation/widgets/entry_editor_bottom_sheet.dart` - Bottom sheet for editing entries
- `lib/features/habits/presentation/widgets/habit_card.dart` - Update existing card with +1 button and heatmap
- `lib/features/habits/presentation/widgets/habit_progress_indicator.dart` - Today's progress display (e.g., "3/8 glasses")
- `lib/features/habits/presentation/widgets/quick_log_button.dart` - Dedicated +1 button widget
- `lib/core/constants/app_colors.dart` - May need to add `getEmberColorWithGlow()` helper for overflow
- `lib/core/utils/date_utils.dart` - Helper for week calculation (Monday start)

### Notes

- Follow Clean Architecture: domain → data → presentation layers
- One widget per file (per EMBER_INSTRUCTIONS.md)
- Use existing `AppColors.ember*` and `AppDimensions.heatmapCell*` constants
- Run `dart run build_runner build` after adding/modifying Riverpod providers
- Week starts on Monday (ISO standard)
- Overflow glow capped at 150%

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [x] 1.0 Create habit entries state management and providers
  - [x] 1.1 Create `lib/core/utils/date_utils.dart` with helper to get current week's date range (Monday–Sunday)
  - [x] 1.2 Create `habit_entries_state.dart` with sealed state class (Initial, Loading, Loaded with entries map, Error)
  - [x] 1.3 Create `habit_entries_viewmodel.dart` using @riverpod annotation with family modifier for habitId
  - [x] 1.4 Implement `loadEntriesForWeek()` method using existing `GetHabitEntries` use case
  - [x] 1.5 Implement `logEntry(date, value)` method using existing `LogHabitEntry` use case
  - [x] 1.6 Implement `incrementToday()` method that adds +1 to today's entry
  - [x] 1.7 Add `habitEntriesViewModelProvider` to `habits_providers.dart`
  - [x] 1.8 Run `dart run build_runner build` to generate provider code

- [x] 2.0 Build the WeekHeatmap widget system
  - [x] 2.1 Update `app_colors.dart` to add `getEmberColorWithGlow(double percentage)` helper that caps at 150%
  - [x] 2.2 Create `heatmap_cell.dart` widget with date, value, dailyGoal, isToday parameters
  - [x] 2.3 Implement cell color logic based on percentage thresholds (0%, 1-25%, 26-50%, 51-75%, 76-100%, 101-150%)
  - [x] 2.4 Add glow effect (BoxDecoration with boxShadow) for cells >100%
  - [x] 2.5 Add today indicator (border ring) styling
  - [x] 2.6 Create `week_heatmap.dart` widget that takes habitId and dailyGoal
  - [x] 2.7 Implement week heatmap layout: Row of 7 HeatmapCell widgets with day labels (M, T, W, T, F, S, S)
  - [x] 2.8 Connect WeekHeatmap to habitEntriesViewModelProvider to get entry data
  - [x] 2.9 Add onCellTap callback to open entry editor for selected date

- [x] 3.0 Build the Entry Editor bottom sheet
  - [x] 3.1 Create `entry_editor_bottom_sheet.dart` widget with habitId, habitName, date, currentValue parameters
  - [x] 3.2 Add header showing habit name and formatted date
  - [x] 3.3 Add numeric TextFormField for value input with validation (>= 0)
  - [x] 3.4 Add "Save" button that calls viewmodel's logEntry method
  - [x] 3.5 Add "Clear" button that sets value to 0 (or deletes entry)
  - [x] 3.6 Dismiss bottom sheet on save and trigger heatmap refresh
  - [x] 3.7 Create helper function `showEntryEditorBottomSheet()` for easy invocation

- [x] 4.0 Update HabitCard with +1 button and progress display
  - [x] 4.1 Create `habit_progress_indicator.dart` widget showing "X/Y unit" format
  - [x] 4.2 Create `quick_log_button.dart` widget with +1 icon/text and onTap callback
  - [x] 4.3 Add animation feedback to quick_log_button (scale or color flash on tap)
  - [x] 4.4 Update `habit_card.dart` layout to include progress indicator and +1 button
  - [x] 4.5 Ensure card tap still navigates to edit habit screen (not quick-log)

- [x] 5.0 Integrate heatmap into home screen habit cards
  - [x] 5.1 Update `habit_card.dart` to include WeekHeatmap widget below habit info
  - [x] 5.2 Pass habit.id and habit.dailyGoal to WeekHeatmap
  - [x] 5.3 Wire up heatmap cell tap to show EntryEditorBottomSheet
  - [x] 5.4 Ensure proper spacing using AppDimensions constants
  - [x] 5.5 Test layout with multiple habits on home screen

- [x] 6.0 Wire up quick-log functionality with optimistic updates
  - [x] 6.1 Connect +1 button to habitEntriesViewModel.incrementToday()
  - [x] 6.2 Implement optimistic UI update (update state before API confirms)
  - [x] 6.3 Update progress indicator immediately on quick-log
  - [x] 6.4 Update heatmap cell color immediately on quick-log
  - [x] 6.5 Handle error case (revert optimistic update if save fails)
  - [x] 6.6 Ensure home screen refreshes entries when returning from background

- [x] 7.0 Final integration and testing
  - [x] 7.8 Run `flutter analyze` and fix any linter issues
  - [ ] 7.1 Test quick-log flow: tap +1, verify progress and heatmap update (manual)
  - [ ] 7.2 Test entry editing: tap cell, modify value, verify heatmap updates (manual)
  - [ ] 7.3 Test overflow glow: log >100% of goal, verify glow effect appears (manual)
  - [ ] 7.4 Test overflow cap: verify glow intensity maxes at 150% (manual)
  - [ ] 7.5 Test past date editing: tap previous day cell, add entry, verify persistence (manual)
  - [ ] 7.6 Test with multiple habits on home screen (manual)
  - [ ] 7.7 Verify today's cell has distinct ring indicator (manual)
