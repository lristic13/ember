# PRD: Habit Logging & Heatmap Visualization

## 1. Introduction/Overview

This feature adds the core habit tracking functionality to Ember: the ability to log daily habit entries and visualize progress through a week-view heatmap. Users will see an inline heatmap directly on the home screen under each habit card, allowing them to quickly log entries with a single tap and see their progress at a glance.

**Problem Solved:** Users can create habits but have no way to track daily progress or visualize their consistency over time. This feature completes the core habit tracking loop.

---

## 2. Goals

1. Enable users to quickly log habit entries with minimal friction (single tap)
2. Provide visual feedback on habit progress through a week-view heatmap
3. Support "overflow" progress visualization to encourage exceeding daily goals
4. Allow users to log/edit entries for any past date for flexibility

---

## 3. User Stories

1. **As a user**, I want to tap on a habit to quickly add +1 to today's entry, so I can log progress without interrupting my flow.

2. **As a user**, I want to see a week-view heatmap under each habit on the home screen, so I can quickly gauge my recent consistency.

3. **As a user**, I want to see brighter/enhanced colors when I exceed my daily goal, so I feel motivated to go beyond the minimum.

4. **As a user**, I want to tap on any day in the heatmap to log or edit an entry for that date, so I can backfill forgotten entries.

5. **As a user**, I want to see today's progress (e.g., "3/8 glasses") displayed clearly, so I know how much more I need to reach my goal.

---

## 4. Functional Requirements

### 4.1 Quick Logging (Home Screen)

1. Each habit card must display a **dedicated "+1" button** for quick increment (tapping the card itself navigates to edit habit, NOT quick-log)
2. Tapping the +1 button must increment today's entry value by 1
3. The UI must provide immediate visual feedback on tap (animation, color change)
4. The current progress for today must be displayed (e.g., "3/8 glasses" or "3/8")

### 4.2 Week-View Heatmap

5. A 7-day horizontal heatmap must be displayed inline below each habit card
6. The heatmap must show the current week starting on **Monday** (Monday–Sunday)
7. Each cell must represent one day and display the day abbreviation (M, T, W, T, F, S, S)
8. Cells must display **color only** (no numeric values inside cells)
9. Today's cell must have a distinct indicator (border, ring, or subtle animation)
10. Cell color intensity must reflect the percentage of daily goal achieved:
    - 0%: `emberNone` (dark/empty)
    - 1–25%: `emberLow`
    - 26–50%: `emberMedium`
    - 51–75%: `emberHigh`
    - 76–100%: `emberMax`
    - 101–150%: Enhanced glow effect using `emberGlow` (overflow visualization, **capped at 150%**)

### 4.3 Entry Editing (Past Dates)

11. Tapping on any heatmap cell must open a bottom sheet or dialog for that date
12. The entry editor must display the selected date clearly
13. The entry editor must show the current logged value (or 0 if no entry)
14. The user must be able to input a custom numeric value (not just +1)
15. The user must be able to clear/delete an entry for that date
16. Changes must save immediately and update the heatmap in real-time

### 4.4 Data & State

17. Entry logging must use the existing `LogHabitEntry` use case
18. Heatmap data must be fetched using the existing `GetHabitEntries` use case
19. The home screen must refresh heatmap data when returning from background or after logging
20. Entries must be stored with date-only precision (no time component)

---

## 5. Non-Goals (Out of Scope)

- Month view or year view heatmaps (future enhancement)
- Streak counting or streak display
- Statistics/analytics screen
- Undo functionality for quick-log
- Haptic feedback (nice-to-have, not required)
- Week navigation (previous/next week) — only current week shown

---

## 6. Design Considerations

### Layout

```
┌─────────────────────────────────────────┐
│  [emoji] Habit Name            [+1]     │
│  3/8 glasses today                      │
│                                         │
│  ┌───┬───┬───┬───┬───┬───┬───┐         │
│  │ M │ T │ W │ T │ F │ S │ S │         │
│  │ ■ │ ■ │ ■ │ ◉ │   │   │   │         │
│  └───┴───┴───┴───┴───┴───┴───┘         │
└─────────────────────────────────────────┘
```

### Visual Guidelines

- Use existing `AppColors.ember*` color constants for heatmap cells
- Cells display **color only** — no numeric values inside
- Overflow (101–150%) should have a subtle glow/bloom effect using `emberGlow`
- Today's cell should have a visible ring or border to distinguish it
- Use `AppDimensions.heatmapCell*` constants for cell sizing
- Cells should have rounded corners matching the app's design language

### Entry Editor Bottom Sheet

- Show habit name and selected date at the top
- Large numeric input field (or stepper) for value
- "Save" and "Clear" buttons
- Keyboard should be numeric

---

## 7. Technical Considerations

### Existing Infrastructure to Leverage

- `LogHabitEntry` use case — already implemented
- `GetHabitEntries` use case — already implemented
- `HabitEntry` entity with `habitId`, `date`, `value`
- `AppColors.getEmberColor(double percentage)` — helper for heatmap colors
- `AppDimensions.heatmapCell*` — sizing constants

### New Components Needed

1. `HabitCardWithHeatmap` — enhanced habit card widget
2. `WeekHeatmap` — 7-day horizontal heatmap widget
3. `HeatmapCell` — individual day cell widget
4. `EntryEditorBottomSheet` — bottom sheet for editing entries
5. Update `HabitsViewModel` to include entry data per habit

### State Management

- The home screen will need to load entries for all habits (current week range)
- Consider a new provider: `habitEntriesProvider(habitId)` for per-habit entries
- Quick-log should optimistically update UI before confirming with repository

---

## 8. Success Metrics

1. **Functional:** User can log an entry and see the heatmap cell update immediately
2. **Functional:** Overflow entries (>100% goal) display enhanced glow effect
3. **Functional:** User can tap any past day and edit/add an entry
4. **Performance:** Heatmap renders smoothly with no visible lag
5. **UX:** Logging a habit takes ≤2 taps from home screen

---

## 9. Resolved Questions

1. ~~Should the "+1" button be on the habit card itself, or should tapping anywhere on the card trigger quick-log?~~
   **Decision:** Dedicated +1 button only. Tapping the card navigates to edit habit.

2. ~~Should we show the numeric value inside each heatmap cell (e.g., "3") or just use color?~~
   **Decision:** Color only, no numeric values in cells.

3. ~~What day should the week start on — Monday (ISO) or Sunday (US locale)?~~
   **Decision:** Monday (ISO standard).

4. ~~Should overflow have a cap (e.g., max 200%) or unlimited glow intensity?~~
   **Decision:** Capped at 150%.
