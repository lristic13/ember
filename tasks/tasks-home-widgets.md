# Tasks: Home Screen Widgets (iOS)

## Relevant Files

### Flutter Side
- `lib/features/widgets/domain/entities/widget_activity_data.dart` - Data model for widget activity information
- `lib/features/widgets/data/services/home_widget_service.dart` - Service for saving data and handling callbacks
- `lib/features/widgets/presentation/providers/home_widget_providers.dart` - Riverpod providers for widget service
- `lib/main.dart` - Initialize widget service and handle deep links
- `lib/core/router/app_router.dart` - Add deep link route handling
- `lib/features/habits/presentation/viewmodels/habit_entries_viewmodel.dart` - Trigger widget updates on entry changes
- `lib/features/habits/domain/usecases/create_habit.dart` - Trigger widget updates on habit changes
- `lib/features/habits/domain/usecases/update_habit.dart` - Trigger widget updates on habit changes
- `lib/features/habits/domain/usecases/delete_habit.dart` - Trigger widget updates on habit deletion

### iOS Side
- `ios/EmberWidget/EmberWidget.swift` - Main widget implementation with SwiftUI view
- `ios/EmberWidget/EmberWidgetBundle.swift` - Widget bundle registration
- `ios/EmberWidget/AppIntent.swift` - Configuration intent for activity selection (ActivityEntity, SelectActivityIntent)
- `ios/Runner/Info.plist` - URL scheme configuration
- `ios/Runner/Runner.entitlements` - App Groups entitlement
- `ios/EmberWidget/EmberWidget.entitlements` - Widget extension App Groups entitlement

### Notes

- The iOS Widget Extension must be created in Xcode (File > New > Target > Widget Extension)
- App Groups must be configured in Apple Developer portal before adding to Xcode
- Test on physical device - widgets often don't work correctly in simulator
- Use `flutter build ios` before testing widget changes to ensure Flutter data is available

---

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

---

## Tasks

- [x] 1.0 Set up Flutter widget infrastructure (data model, service, providers)
  - [x] 1.1 Add `home_widget: ^0.6.0` dependency to `pubspec.yaml` and run `flutter pub get`
  - [x] 1.2 Create `lib/features/widgets/` directory structure (domain/entities, data/services, presentation/providers)
  - [x] 1.3 Create `WidgetActivityData` entity with fields: id, name, emoji, isCompletion, unit, todayValue, currentStreak, weekValues, gradientId
  - [x] 1.4 Implement `toJson()` and `fromJson()` methods on `WidgetActivityData`
  - [x] 1.5 Create `HomeWidgetService` class with App Group ID constant
  - [x] 1.6 Implement `initialize()` method to set App Group ID and register click listener
  - [x] 1.7 Implement `_buildWidgetData(Habit habit)` method to construct `WidgetActivityData` from habit and entries
  - [x] 1.8 Implement `_calculateCurrentWeekValues(String habitId)` to get Mon-Sun values for current week
  - [x] 1.9 Implement `updateActivityWidget(String habitId)` to save single activity data to shared storage
  - [x] 1.10 Implement `updateAllWidgets()` to save all non-archived activities and available activities list
  - [x] 1.11 Create Riverpod provider for `HomeWidgetService`

- [x] 2.0 Configure iOS project for widgets (App Groups, URL scheme, Widget Extension target)
  - [x] 2.1 Open `ios/Runner.xcworkspace` in Xcode
  - [x] 2.2 Create App Group in Apple Developer portal (`group.com.lristic.ember`)
  - [x] 2.3 Add App Groups capability to Runner target and select the created group
  - [x] 2.4 Add Widget Extension target: File > New > Target > Widget Extension, name it "EmberWidget"
  - [x] 2.5 When prompted, choose "Include Configuration App Intent" for activity selection
  - [x] 2.6 Add App Groups capability to EmberWidget target and select the same group
  - [x] 2.7 Add URL scheme to `ios/Runner/Info.plist` (`ember://`)
  - [x] 2.8 Verify both targets have matching App Group ID
  - [x] 2.9 Update `HomeWidgetService` with correct App Group ID constant

- [x] 3.0 Implement iOS Widget UI with SwiftUI
  - [x] 3.1 Create `EmberEntry` struct conforming to `TimelineEntry` with all activity fields
  - [x] 3.2 Create static `placeholder` entry for widget preview
  - [x] 3.3 Implement `Provider` struct conforming to `AppIntentTimelineProvider`
  - [x] 3.4 Implement `getEntry()` helper to read activity data from UserDefaults (App Group)
  - [x] 3.5 Implement `placeholder()`, `snapshot()`, and `timeline()` methods in Provider
  - [x] 3.6 Set timeline refresh policy to 15 minutes
  - [x] 3.7 Create `EmberWidgetEntryView` SwiftUI view
  - [x] 3.8 Implement header section with emoji and activity name
  - [x] 3.9 Implement status text (quantity: "X unit today", completion: "Done/Not yet today")
  - [x] 3.10 Implement streak display with fire emoji
  - [x] 3.11 Implement mini heat map (7 rounded rectangles for Mon-Sun)
  - [x] 3.12 Implement day labels row (M, T, W, T, F, S, S)
  - [x] 3.13 Implement circular action button ("+" for quantity, "✓" for completion)
  - [x] 3.14 Create `gradientColor` computed property mapping all 20 gradient IDs to SwiftUI Colors
  - [x] 3.15 Implement `cellColor(for:)` method for heat map cell coloring
  - [x] 3.16 Apply dark background (#0D0D0F) and proper text colors
  - [x] 3.17 Configure widget to support `.systemMedium` family only
  - [x] 3.18 Set `widgetURL` for tap-to-open functionality

- [x] 4.0 Implement Widget Configuration Intent (activity selection)
  - [x] 4.1 Create `ActivityEntity` struct conforming to `AppEntity` with id, name, emoji
  - [x] 4.2 Implement `ActivityEntityQuery` conforming to `EntityQuery`
  - [x] 4.3 Implement `entities(for:)` to return activities matching given IDs
  - [x] 4.4 Implement `suggestedEntities()` to return all available activities from UserDefaults
  - [x] 4.5 Create `SelectActivityIntent` conforming to `WidgetConfigurationIntent`
  - [x] 4.6 Add `@Parameter` for selected activity entity
  - [x] 4.7 Update Provider to use `AppIntentTimelineProvider` with `SelectActivityIntent`
  - [x] 4.8 Update `getEntry()` to read selected activity ID from intent configuration
  - [x] 4.9 Update widget configuration to use `AppIntentConfiguration` instead of `StaticConfiguration`
  - [ ] 4.10 Test activity selection in widget edit mode

- [x] 5.0 Implement quick-log functionality and callbacks
  - [x] 5.1 Add `Link` wrapper to action button with URL `ember://log?habitId={id}`
  - [x] 5.2 In `main.dart`, implement `_handleWidgetUri(Uri uri)` callback
  - [x] 5.3 Parse URI to extract action (log/open) and habitId
  - [x] 5.4 Handle quick-log via HomeWidgetService
  - [x] 5.5 For quantity type: get today's entry, add +1, save entry
  - [x] 5.6 For completion type: get today's entry, toggle between 0 and 1, save entry
  - [x] 5.7 After logging, call `updateActivityWidget(habitId)` to refresh widget immediately
  - [x] 5.8 Ensure entry saving uses existing repository/use case pattern
  - [ ] 5.9 Test quick-log from widget updates both app data and widget display

- [x] 6.0 Implement deep linking from widget to app
  - [x] 6.1 In iOS widget, set `widgetURL` to `ember://open?habitId={id}`
  - [x] 6.2 In `main.dart _handleWidgetUri`, handle "open" action
  - [x] 6.3 Create navigation method to open specific habit detail screen via appRouter.go()
  - [x] 6.4 URL scheme configured in Info.plist for deep links
  - [x] 6.5 In `main.dart`, check for initial widget click URI on app start
  - [x] 6.6 Handle case where app is already running (HomeWidget.widgetClicked listener)
  - [ ] 6.7 Test tapping widget body opens correct activity detail screen

- [x] 7.0 Integrate widget updates with existing app flows
  - [x] 7.1 Initialize `HomeWidgetService` in `main.dart` before `runApp()`
  - [x] 7.2 Call `updateAllWidgets()` on app startup to ensure fresh data
  - [x] 7.3 In entry save/update flow, call `updateActivityWidget(habitId)` after successful save
  - [x] 7.4 In habit create flow, call `updateAllWidgets()` after successful creation
  - [x] 7.5 In habit update flow, call `updateActivityWidget(habitId)` after successful update
  - [x] 7.6 In habit delete/archive flow, call `updateAllWidgets()` after successful operation
  - [x] 7.7 Ensure widget updates happen after database commits (not optimistically)
  - [x] 7.8 Handle "Activity not found" state in widget when activity is deleted

- [ ] 8.0 Testing and polish
  - [ ] 8.1 Test widget on physical iOS device (simulator widgets unreliable)
  - [ ] 8.2 Verify all 20 gradient colors display correctly
  - [ ] 8.3 Test quick-log for quantity type (+1 increments correctly)
  - [ ] 8.4 Test quick-log for completion type (toggles correctly)
  - [ ] 8.5 Test widget refresh after logging in-app
  - [ ] 8.6 Test activity selection in widget configuration
  - [ ] 8.7 Test deep link opens correct activity detail
  - [ ] 8.8 Test widget displays "Activity not found" after deletion
  - [ ] 8.9 Test streak calculation matches app display
  - [ ] 8.10 Test heat map shows correct week values
  - [ ] 8.11 Verify widget preview image in widget gallery
  - [ ] 8.12 Test widget behavior after device restart
  - [ ] 8.13 Run `flutter analyze` and fix any issues
