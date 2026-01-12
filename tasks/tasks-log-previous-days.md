# Tasks: Log Previous Days Feature

## Relevant Files

- `lib/features/habits/presentation/widgets/entry_editor_bottom_sheet.dart` - Entry editor that needs to display the date being edited
- `lib/features/habits/presentation/widgets/week_heatmap.dart` - Week heatmap on habit cards (home screen)
- `lib/features/habits/presentation/widgets/heatmap_cell.dart` - Individual cell for week heatmap
- `lib/features/habits/presentation/widgets/month_heatmap.dart` - Month heatmap on habit details screen
- `lib/features/habits/presentation/widgets/month_heatmap_cell.dart` - Individual cell for month heatmap
- `lib/features/habits/presentation/widgets/habit_grid_card.dart` - Grid card on home screen month view
- `lib/features/habits/presentation/widgets/mini_month_heatmap.dart` - Mini month heatmap used in grid cards and year view
- `lib/features/habits/presentation/widgets/year_month_grid.dart` - Year view grid of months
- `lib/features/habits/presentation/widgets/year_heatmap_content.dart` - Year heatmap screen content
- `lib/features/habits/presentation/screens/year_heatmap_screen.dart` - Year heatmap screen
- `lib/features/habits/presentation/widgets/habit_card.dart` - Habit card that shows entry editor on cell tap
- `lib/features/habits/presentation/widgets/habit_details_content.dart` - Habit details content with month heatmap
- `lib/core/constants/app_strings.dart` - String constants for date formatting labels
- `lib/core/utils/date_utils.dart` - Date utility functions for formatting

### Notes

- The `onCellTap` callback pattern already exists in most heatmap widgets
- The entry editor already supports editing via the `currentValue` parameter
- Need to ensure `habitIntensitiesProvider` is invalidated after changes (already done in existing code)
- Use `intl` package for date formatting

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [x] 0.0 Create feature branch
  - [x] 0.1 Create and checkout a new branch for this feature (`git checkout -b feature/log-previous-days`)

- [x] 1.0 Update entry editor to display the date being edited
  - [x] 1.1 Add `date` parameter to `showEntryEditorBottomSheet` function (already existed)
  - [x] 1.2 Create a helper function to format the date display (e.g., "Today", "Yesterday", "Mon, Jan 12")
  - [x] 1.3 Update the bottom sheet header to show the formatted date alongside "Log Entry" (already existed)
  - [x] 1.4 Add string constants to `app_strings.dart` for date labels (e.g., "Today", "Yesterday")

- [x] 2.0 Enable cell tapping on week heatmap (home screen habit cards)
  - [x] 2.1 Verify `HabitCard` already passes `onCellTap` to `WeekHeatmap` with date and value (already implemented)
  - [x] 2.2 Verify `WeekHeatmap` passes tap handler to `HeatmapCell` components (already implemented)
  - [x] 2.3 Update `_showEntryEditor` in `HabitCard` to pass the date to the entry editor (already implemented)
  - [x] 2.4 Test tapping cells on week heatmap opens editor with correct date

- [x] 3.0 Enable cell tapping on month heatmap (habit details screen)
  - [x] 3.1 Review current `MonthHeatmap` onCellTap implementation
  - [x] 3.2 Update `HabitDetailsContent` to show entry editor instead of tooltip on cell tap
  - [x] 3.3 Ensure the entry editor receives the correct date and current value
  - [x] 3.4 Test tapping cells on month heatmap opens editor with correct date

- [x] 4.0 Enable cell tapping on month grid view (home screen)
  - [x] 4.1 Add `onCellTap` callback parameter to `HabitGridCard`
  - [x] 4.2 Pass `onCellTap` from `HabitGridCard` to `MiniMonthHeatmap`
  - [x] 4.3 Implement `_showEntryEditor` method in `HabitGridCard`
  - [x] 4.4 Test tapping cells on grid cards opens editor with correct date

- [x] 5.0 Enable cell tapping on year view heatmap
  - [x] 5.1 Add `habitId` and `habitName` and `unit` parameters to `YearHeatmapContent`
  - [x] 5.2 Pass these parameters through `YearMonthGrid` to `MiniMonthHeatmap` (already done via onCellTap)
  - [x] 5.3 Implement entry editor display on cell tap in year view
  - [x] 5.4 Update `YearHeatmapScreen` to pass required parameters
  - [x] 5.5 Test tapping cells on year view opens editor with correct date

- [x] 6.0 Implement future date restriction
  - [x] 6.1 Add logic to check if a date is in the future in date utils
  - [x] 6.2 Update `HeatmapCell` to disable tap for future dates
  - [x] 6.3 Update `MonthHeatmapCell` to disable tap for future dates
  - [x] 6.4 Update `MiniMonthHeatmap` cells to disable tap for future dates
  - [x] 6.5 Optionally reduce opacity for future date cells to indicate non-interactivity

- [ ] 7.0 Test and verify all heatmap interactions
  - [ ] 7.1 Test logging entry for past date on week heatmap (home screen)
  - [ ] 7.2 Test logging entry for past date on month heatmap (habit details)
  - [ ] 7.3 Test logging entry for past date on grid view (home screen month view)
  - [ ] 7.4 Test logging entry for past date on year view
  - [ ] 7.5 Verify future dates are not tappable
  - [ ] 7.6 Verify all heatmaps update immediately after entry changes
  - [ ] 7.7 Verify editing existing entries works correctly
  - [ ] 7.8 Verify clearing/deleting entries works correctly
