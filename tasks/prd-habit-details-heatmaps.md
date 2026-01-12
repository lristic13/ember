# PRD: Habit Details Page with Month & Year Heatmaps

## 1. Introduction/Overview

This feature introduces a dedicated Habit Details page that serves as an intermediate view between the home screen and the edit habit page. When users tap on a habit card, they'll see comprehensive habit information including statistics and expanded heatmap visualizations (month and year views). This replaces the current behavior of navigating directly to the edit page.

**Problem Solved:** Users currently can only see a week-view heatmap on the home screen. They have no way to visualize their long-term progress or view statistics about their habits. This feature provides deeper insights into habit performance over time.

---

## 2. Goals

1. Provide a dedicated page for viewing detailed habit progress and statistics
2. Implement month-view heatmap as a calendar grid for medium-term visualization
3. Implement year-view heatmap showing 12 mini-months for long-term visualization
4. Allow navigation through historical months and years
5. Maintain easy access to the edit habit functionality

---

## 3. User Stories

1. **As a user**, I want to tap on a habit and see detailed statistics (streak, total, average), so I can understand my overall progress.

2. **As a user**, I want to see a month-view calendar heatmap, so I can visualize my consistency throughout the current month.

3. **As a user**, I want to tap the month heatmap to see a full year view with 12 mini-months, so I can see long-term patterns.

4. **As a user**, I want to navigate to previous months and years, so I can review my historical progress.

5. **As a user**, I want to tap on any heatmap cell to see a tooltip showing the date and logged value.

6. **As a user**, I want to access the edit habit page from the details page, so I can modify habit settings when needed.

---

## 4. Functional Requirements

### 4.1 Navigation Changes

1. Tapping a habit card on the home screen must navigate to the new Habit Details page (not Edit Habit)
2. The Habit Details page must include an "Edit" button (icon or text) in the app bar
3. Tapping the Edit button must navigate to the existing Edit Habit page
4. The back button from Habit Details must return to the home screen

### 4.2 Habit Details Page - Header Section

5. Display the habit emoji (or fire icon) prominently
6. Display the habit name as the page title
7. Display the daily goal with unit (e.g., "Goal: 8 glasses / day")

### 4.3 Statistics Section

8. Display **Current Streak**: consecutive days goal was met (ending today or yesterday)
9. Display **Longest Streak**: best consecutive days ever achieved
10. Display **Total Logged**: sum of all entry values
11. Display **Daily Average**: average value per day (for days with entries)
12. Statistics should be displayed in a visually appealing card or grid layout

### 4.4 Month Heatmap View

13. Display a calendar-style grid: 7 columns (Mon-Sun) × 4-6 rows (weeks in month)
14. Show day-of-week headers (M, T, W, T, F, S, S)
15. Show the month and year as a header (e.g., "January 2026")
16. Include left/right navigation arrows to move between months
17. Each cell displays the day number
18. Cell background color uses the ember gradient based on goal completion percentage
19. Today's cell must have a distinct indicator (border/ring)
20. Cells outside the current month should be dimmed or hidden
21. Tapping a cell shows a tooltip with date and logged value
22. Tapping the month heatmap area (or a "View Year" button) navigates to Year View

### 4.5 Year Heatmap View (Separate Screen)

23. Display 12 mini-month grids in a 4×3 or 3×4 arrangement
24. Each mini-month shows a simplified calendar grid (smaller cells, no day numbers)
25. Show the year as a header (e.g., "2026")
26. Include left/right navigation arrows to move between years
27. Each mini-month is labeled with its abbreviated name (Jan, Feb, etc.)
28. Cell colors use the ember gradient based on goal completion
29. Tapping a cell shows a tooltip with date and logged value
30. Tapping a mini-month could optionally navigate back to Month View for that month

### 4.6 Tooltip Behavior

31. Tooltip appears near the tapped cell
32. Tooltip displays the formatted date (e.g., "Mon, Jan 6")
33. Tooltip displays the logged value and unit (e.g., "5 glasses") or "No entry" if empty
34. Tooltip dismisses when tapping elsewhere

---

## 5. Non-Goals (Out of Scope)

- Editing entries from Month/Year views (only tooltips, no entry editor)
- Exporting or sharing heatmap images
- Comparing multiple habits side-by-side
- Goal adjustment history or tracking
- Animated transitions between heatmap views
- Pinch-to-zoom on heatmaps

---

## 6. Design Considerations

### Habit Details Page Layout

```
┌─────────────────────────────────────────┐
│  ←  Habit Details              [Edit]   │  ← App Bar
├─────────────────────────────────────────┤
│                                         │
│           [🔥 or emoji]                 │
│           Drink Water                   │
│         Goal: 8 glasses / day           │
│                                         │
├─────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐              │
│  │ Current │  │ Longest │              │
│  │ Streak  │  │ Streak  │              │
│  │   12    │  │   28    │              │
│  │  days   │  │  days   │              │
│  └─────────┘  └─────────┘              │
│  ┌─────────┐  ┌─────────┐              │
│  │  Total  │  │  Daily  │              │
│  │ Logged  │  │ Average │              │
│  │  1,247  │  │   6.2   │              │
│  │ glasses │  │ glasses │              │
│  └─────────┘  └─────────┘              │
├─────────────────────────────────────────┤
│         ◀  January 2026  ▶             │
│                                         │
│    M   T   W   T   F   S   S           │
│   ┌───┬───┬───┬───┬───┬───┬───┐        │
│   │   │   │ 1 │ 2 │ 3 │ 4 │ 5 │        │
│   ├───┼───┼───┼───┼───┼───┼───┤        │
│   │ 6 │ 7 │ 8 │...│...│...│...│        │
│   └───┴───┴───┴───┴───┴───┴───┘        │
│              [View Year]                │
└─────────────────────────────────────────┘
```

### Year View Layout

```
┌─────────────────────────────────────────┐
│  ←  Year View                           │
├─────────────────────────────────────────┤
│              ◀  2026  ▶                 │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │   Jan   │ │   Feb   │ │   Mar   │   │
│  │ ▪▪▪▪▪▪▪ │ │ ▪▪▪▪▪▪▪ │ │ ▪▪▪▪▪▪▪ │   │
│  │ ▪▪▪▪▪▪▪ │ │ ▪▪▪▪▪▪▪ │ │ ▪▪▪▪▪▪▪ │   │
│  │ ▪▪▪▪▪▪▪ │ │ ▪▪▪▪▪▪▪ │ │ ▪▪▪▪▪▪▪ │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │   Apr   │ │   May   │ │   Jun   │   │
│  │ ...     │ │ ...     │ │ ...     │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│         ... (continues for 12 months)   │
└─────────────────────────────────────────┘
```

### Visual Guidelines

- Use existing `AppColors.ember*` constants for cell colors
- Statistics cards should use `AppColors.surface` background
- Navigation arrows should be subtle but tappable (icon buttons)
- Mini-month cells in year view should be smaller (use `heatMapCellSize` not `weekHeatMapCellSize`)
- Tooltips should use `AppColors.surfaceLight` with `AppColors.textPrimary`

---

## 7. Technical Considerations

### New Routes Required

- `/habits/:id` — Habit Details page
- `/habits/:id/year` — Year View page

### Existing Infrastructure to Leverage

- `GetHabitEntries.inRange()` — fetch entries for month/year ranges
- `HabitEntriesViewModel` — may need to extend for larger date ranges
- `AppColors.getEmberColorWithGlow()` — for cell coloring

### New Components Needed

1. `HabitDetailsScreen` — main details page
2. `HabitStatisticsCard` — displays streak, total, average
3. `MonthHeatmap` — calendar grid for single month
4. `MonthHeatmapCell` — individual day cell with day number
5. `YearHeatmapScreen` — year view page
6. `MiniMonthHeatmap` — compact month grid for year view
7. `HeatmapTooltip` — popup showing date and value
8. `HeatmapNavigation` — month/year navigation arrows

### Statistics Calculation

- **Current Streak**: Count consecutive days (ending today or yesterday) where `value >= dailyGoal`
- **Longest Streak**: Maximum consecutive days where `value >= dailyGoal`
- **Total Logged**: Sum of all `entry.value`
- **Daily Average**: `Total Logged / number of days with entries`

---

## 8. Success Metrics

1. **Functional:** User can navigate from home → habit details → year view → back
2. **Functional:** Month navigation shows correct data for selected month
3. **Functional:** Year navigation shows correct data for selected year
4. **Functional:** Statistics display accurate streak, total, and average values
5. **Functional:** Tooltip shows correct date and value on cell tap
6. **UX:** Habit details page loads quickly with all statistics visible

---

## 9. Resolved Questions

1. ~~What additional information should be shown on the Habit Details page?~~
   **Decision:** Heatmaps + statistics (streak, total logged, average per day)

2. ~~For the Month heatmap view, what layout?~~
   **Decision:** Calendar grid (7 columns for days of week, rows for weeks in month)

3. ~~For the Year heatmap view, what layout?~~
   **Decision:** 12 mini-month grids arranged in a grid (4×3 or 3×4)

4. ~~Should month/year navigation be included?~~
   **Decision:** Yes - allow navigating to previous months/years

5. ~~What should happen when tapping a cell in Month or Year heatmap?~~
   **Decision:** Show a tooltip/popup with date and value (no editing from these views)
