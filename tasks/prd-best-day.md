# PRD: Best Day Statistic

## Introduction/Overview

Add a "Best Day" statistic to the habit details page that shows users which day of the week they perform best for measured (quantity) activities. This helps users identify patterns in their behavior and understand when they're most productive or consistent with their habits.

For example, if a user tracks "Glasses of Water" and consistently drinks more on Wednesdays, the statistic would show "Wednesday" as their best day.

## Goals

1. Help users identify their most productive day of the week for each measured activity
2. Provide actionable insights that encourage habit consistency
3. Enhance the statistics section with meaningful, personalized data

## User Stories

1. **As a user tracking a measured activity**, I want to see which day of the week I perform best, so I can understand my behavior patterns.

2. **As a user**, I want the best day calculation to be based on my average performance per weekday, so the result reflects my typical behavior rather than a single outlier.

## Functional Requirements

1. The system must calculate the average value logged for each day of the week (Monday–Sunday) for a given habit.

2. The system must identify the day of the week with the highest average value as the "Best Day."

3. The system must display the best day statistic only for **quantity/measured** tracking types. Completion-type activities should not show this statistic.

4. The system must display the best day as a new row below the existing 2x2 statistics grid, making it a 5th statistic.

5. The statistic should display:
   - Label: "Best Day"
   - Value: The weekday name (e.g., "Monday", "Tuesday")
   - Optional: The average value for that day (e.g., "8.5 glasses")

6. The system must show this statistic immediately, even with only 1 day of data logged.

7. If no data exists, the statistic should not be displayed (or show a placeholder like "—").

8. If multiple days tie for the highest average, display the earliest day of the week (Monday takes precedence over Tuesday, etc.).

## Non-Goals (Out of Scope)

- Best day calculation for completion-type activities
- "Worst day" or other comparative day statistics
- Historical trends showing how best day has changed over time
- Notifications or suggestions based on best day data

## Design Considerations

- The new statistic should match the existing `StatisticItem` widget styling
- Display in a single centered row below the current 2x2 grid
- Use the habit's accent color for the value text (consistent with other stats)
- Consider showing the average value as the "unit" portion (e.g., "Wednesday" with "avg 8.5 glasses")

## Technical Considerations

- Extend `StatisticsCalculator` with a new method: `calculateBestDay(List<HabitEntry> entries)`
- Update `HabitStatisticsState` to include `bestDay` (String?) and optionally `bestDayAverage` (double?)
- Update `HabitStatisticsViewModel` to calculate and include best day in the state
- Update `HabitStatisticsCard` to conditionally render the best day row for quantity types
- The calculation should group entries by weekday (using `DateTime.weekday`), calculate averages, and return the day with the highest average

## Success Metrics

- Feature is displayed correctly for all quantity-type activities
- Feature is hidden for completion-type activities
- Calculation correctly identifies the day with the highest average value

## Open Questions

~1. Should the average value for the best day be displayed alongside the day name, or just the day name alone?~
**Decision:** Just show the day name.

~2. Should we localize day names or use English throughout?~
**Decision:** Keep English day names.
