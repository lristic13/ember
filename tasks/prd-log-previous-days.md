# PRD: Log Previous Days

## Introduction/Overview

Currently, users can only quickly log entries for the current day using the "+" button on habit cards. This feature enables users to log entries for any past date by tapping on heatmap cells throughout the app. This addresses the common scenario where users forget to log an activity on a given day and need to backfill their data.

## Goals

1. Allow users to log habit entries for any past date
2. Provide a seamless experience for editing and deleting past entries
3. Maintain data integrity and consistency across all heatmap views

## User Stories

1. **As a user**, I want to tap on any heatmap cell to log an entry for that specific date, so I can record activities I forgot to log.

2. **As a user**, I want to edit an entry I previously logged for a past date, so I can correct mistakes.

3. **As a user**, I want to delete an entry for a past date, so I can remove incorrect data.

4. **As a user**, I want the entry editor to clearly show which date I'm logging for, so I don't accidentally log for the wrong day.

## Functional Requirements

1. **Tappable Heatmap Cells**: All heatmap cells (week view on home screen, month view on home screen, month view in habit details, year view) must be tappable to open the entry editor for that specific date.

2. **Entry Editor Date Display**: The entry editor bottom sheet must clearly display the date being edited (e.g., "Log Entry - Jan 12, 2026" or "Today" for current date).

3. **Past Date Logging**: The system must allow logging entries for any past date with no time restrictions.

4. **Future Date Restriction**: The system should NOT allow logging entries for future dates. Future date cells should either be non-tappable or show an appropriate message.

5. **Edit Existing Entries**: When tapping a cell that already has an entry, the editor must pre-populate with the existing value, allowing the user to modify it.

6. **Delete Entries**: The entry editor must provide a way to delete/clear an existing entry (already exists via "Clear" button).

7. **Immediate UI Update**: After saving or deleting an entry, all visible heatmaps must immediately reflect the change without requiring manual refresh.

8. **Consistent Behavior**: The entry editor behavior must be consistent regardless of which heatmap view it was opened from.

## Non-Goals (Out of Scope)

- Bulk editing of multiple days at once
- Import/export of historical data
- Visual distinction between retroactively logged entries and same-day entries
- Date picker within the entry editor (users tap the specific cell instead)
- Logging entries for future dates

## Design Considerations

- The entry editor bottom sheet already exists (`entry_editor_bottom_sheet.dart`)
- The date should be prominently displayed in the editor header
- Format the date in a user-friendly way (e.g., "Today", "Yesterday", "Mon, Jan 12")
- Cells for future dates should appear visually disabled or non-interactive

## Technical Considerations

- The `onCellTap` callback already exists on most heatmap widgets and passes the date and current value
- The entry editor already supports editing via the `currentValue` parameter
- Need to ensure `habitIntensitiesProvider` is invalidated after changes to update all heatmaps
- Week heatmap on habit cards already has `onCellTap` implemented
- Month heatmap cells need to pass through the tap to show the editor
- Year view mini-month cells may need the tap handler connected

## Success Metrics

1. Users can successfully log entries for any past date via heatmap cell tap
2. All heatmap views update immediately after entry changes
3. No regression in existing quick-log functionality (+ button for today)

## Open Questions

1. Should we show a toast/snackbar confirmation after successfully logging a past entry?
2. Should empty cells for past dates have a different visual treatment to indicate they're tappable (e.g., subtle border on hover/tap)?
