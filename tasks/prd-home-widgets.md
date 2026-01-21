# PRD: Home Screen Widgets

## Introduction/Overview

Home screen widgets allow Ember users to quickly view and log their activities without opening the app. Each widget displays a single activity with today's status, current streak, a mini heat map of the current week, and a quick-log button.

This feature addresses the friction of opening the app multiple times per day to log habits. By providing at-a-glance information and one-tap logging directly from the home screen, users can maintain their streaks more easily and stay engaged with their activity tracking.

---

## Goals

1. **Reduce logging friction** - Enable users to log activities with a single tap from their home screen
2. **Increase visibility** - Keep activity progress visible throughout the day without opening the app
3. **Improve streak retention** - Visual streak and heat map reminders help users maintain consistency
4. **Platform-native experience** - Widgets should feel native to each platform (iOS first, Android later)

---

## User Stories

### US1: View Activity Status at a Glance
> As a user, I want to see my activity's current status on my home screen so that I can quickly check my progress without opening the app.

### US2: Quick Log from Home Screen
> As a user, I want to log my activity with one tap from the widget so that tracking takes minimal effort.

### US3: Track Streak Progress
> As a user, I want to see my current streak on the widget so that I'm motivated to maintain it.

### US4: View Weekly Progress
> As a user, I want to see a mini heat map of my current week so that I can identify patterns at a glance.

### US5: Choose Which Activity to Display
> As a user, I want to select which activity appears in my widget so that I can prioritize what's most important to me.

### US6: Navigate to Activity Details
> As a user, I want to tap the widget to open the app directly to that activity so that I can see more details or make adjustments.

---

## Functional Requirements

### Widget Display

1. **FR1:** The widget MUST display the activity's emoji and name in the header
2. **FR2:** The widget MUST show today's value/status:
   - Quantity type: "{value} {unit} today" (e.g., "8 glasses today")
   - Completion type: "Done today" or "Not yet today"
3. **FR3:** The widget MUST display the current streak with fire emoji (e.g., "🔥 5 days")
4. **FR4:** The widget MUST show a mini heat map of the current week (Monday-Sunday, 7 cells)
5. **FR5:** The widget MUST display day labels (M, T, W, T, F, S, S) below the heat map
6. **FR6:** The widget MUST show an action button:
   - Quantity type: "+" button
   - Completion type: "✓" button
7. **FR7:** The widget MUST use the activity's gradient color for visual theming

### Widget Interactions

8. **FR8:** Tapping the "+" or "✓" button MUST log the activity directly:
   - Quantity type: Adds +1 to today's value
   - Completion type: Toggles between done (1) and not done (0)
9. **FR9:** Tapping anywhere else on the widget MUST open the app to that activity's detail screen
10. **FR10:** After quick-logging, the widget MUST refresh immediately to show the updated value

### Widget Configuration (iOS Only)

11. **FR11:** Users MUST be able to select which activity to display using the native iOS widget configuration UI
12. **FR12:** The configuration MUST show a list of all non-archived activities with their emoji and name
13. **FR13:** The selected activity MUST persist across device restarts

### Data Synchronization

14. **FR14:** Widget data MUST refresh immediately when the user logs an entry in the main app
15. **FR15:** Widget data MUST refresh immediately when the user modifies an activity (name, emoji, etc.)
16. **FR16:** Widget data MUST refresh periodically in the background (every 15 minutes minimum on iOS)
17. **FR17:** The Flutter app MUST save widget data to shared storage (UserDefaults via App Groups on iOS)

### Error Handling

18. **FR18:** If the selected activity is deleted or archived, the widget MUST display "Activity not found" with a prompt to tap and reconfigure
19. **FR19:** If no activity is selected, the widget MUST display a placeholder prompting the user to configure it

### Data Model

20. **FR20:** The widget data model MUST include:
    - `id` - Activity ID
    - `name` - Activity name
    - `emoji` - Activity emoji (optional)
    - `isCompletion` - Whether it's a completion type activity
    - `unit` - Unit for quantity type (optional)
    - `todayValue` - Today's logged value
    - `currentStreak` - Current consecutive days
    - `weekValues` - Array of 7 values (Mon-Sun)
    - `gradientId` - Activity's color theme

---

## Non-Goals (Out of Scope)

1. **Android implementation** - Will be addressed in a follow-up phase
2. **Multiple activities per widget** - Each widget shows one activity only
3. **Widget size variants** - Only medium size widget for initial release
4. **Historical data beyond current week** - Heat map shows current week only
5. **Custom quick-log amounts** - Quick log is always +1 or toggle; custom amounts require opening the app
6. **Lock screen widgets** - Home screen only for initial release
7. **Watch complications** - Apple Watch support is out of scope
8. **In-app widget management screen** - Configuration is via native iOS widget edit only

---

## Design Considerations

### Widget Layout (Medium Size - 329x155 pt)

**Quantity Type:**
```
┌─────────────────────────────────┐
│  💧 Water                       │
│  8 glasses today   🔥 5 days    │
│                                 │
│  [ ▪ ▪ ▪ ░ ▪ ▪ ░ ]             │
│    M T W T F S S               │
│                                 │
│            [ + ]                │
└─────────────────────────────────┘
```

**Completion Type:**
```
┌─────────────────────────────────┐
│  🏋️ Workout                     │
│  Done today        🔥 2 days    │
│                                 │
│  [ ░ ▪ ▪ ░ ▪ ▪ ░ ]             │
│    M T W T F S S               │
│                                 │
│            [ ✓ ]                │
└─────────────────────────────────┘
```

### Visual Styling

- **Background:** Dark (#0D0D0F) to match app theme
- **Text colors:** Primary (#F5F5F5), Secondary (#A0A0A0)
- **Heat map cells:** Filled cells use activity gradient color, empty cells use (#1A1A1E)
- **Action button:** Circular, uses activity gradient color with white icon

### Color Mapping

The widget must support all 20 gradient presets from the app:
- ember, coral, sunflower, mint, ocean, lavender, rose, teal, sand, silver
- ruby, peach, lime, sky, violet, magenta, amber, sage, slate, copper

---

## Technical Considerations

### Dependencies

```yaml
dependencies:
  home_widget: ^0.6.0
```

### Architecture

```
Flutter App                          iOS Native
┌─────────────────┐                 ┌─────────────────┐
│ HomeWidgetService│ ──UserDefaults──▶│ EmberWidget     │
│ - Save data      │   (App Group)   │ (WidgetKit)     │
│ - Handle callbacks│◀──URL Scheme───│ - SwiftUI View  │
└─────────────────┘                 └─────────────────┘
```

### iOS Requirements

1. **Widget Extension** - New target "EmberWidget" in Xcode
2. **App Groups** - Shared container for data (e.g., `group.com.ember.app`)
3. **URL Scheme** - `ember://` for deep linking from widget
4. **WidgetKit Configuration Intent** - For activity selection

### Key Files to Create/Modify

**Flutter Side:**
- `lib/features/widgets/domain/entities/widget_activity_data.dart` - Data model
- `lib/features/widgets/data/services/home_widget_service.dart` - Service layer
- `lib/features/widgets/presentation/providers/home_widget_providers.dart` - Riverpod providers

**iOS Side:**
- `ios/EmberWidget/EmberWidget.swift` - Main widget implementation
- `ios/EmberWidget/EmberWidgetBundle.swift` - Widget bundle
- `ios/Runner/Info.plist` - URL scheme configuration

### Existing Code Integration

- Use `StatisticsCalculator.calculateCurrentStreak()` for streak calculation
- Use existing `HabitEntry` and `Habit` entities (map to widget data model)
- Integrate with existing entry logging flow to trigger widget updates

### Terminology Mapping

The app internally uses "Habit" but displays "Activity" to users:
- `Habit` entity → `WidgetActivityData.name` (activity name)
- `HabitEntry` → Widget's `todayValue` and `weekValues`
- `habit.isQuantity` → `WidgetActivityData.isCompletion` (inverted)

---

## Success Metrics

1. **Widget adoption rate** - % of users who add at least one widget within 7 days of update
2. **Quick-log usage** - % of daily logs that come from widget vs. in-app
3. **Streak improvement** - Compare average streak length before/after widget release
4. **App open reduction** - Measure if quick-log reduces unnecessary app opens while maintaining engagement

---

## Implementation Phases

### Phase 1: iOS Implementation (This PRD)
- Flutter HomeWidgetService
- iOS Widget Extension with WidgetKit
- Native configuration intent for activity selection
- Quick-log functionality
- Deep linking to activity detail

### Phase 2: Android Implementation (Future PRD)
- Android Widget using Glance/XML
- Android-specific configuration (may be manual/in-app)
- Equivalent functionality to iOS

---

## Open Questions

1. **App Group ID** - What should the App Group identifier be? (e.g., `group.com.ember.app`)
2. **Bundle ID** - Confirm the iOS bundle identifier for proper URL scheme setup
3. **Analytics** - Should we track widget interactions separately for analytics?
4. **Onboarding** - Should we prompt users to add a widget after creating their first activity?
5. **Widget Gallery Preview** - What preview image should show in the iOS widget gallery?

---

## Checklist

### Flutter Side
- [ ] Create `WidgetActivityData` model
- [ ] Create `HomeWidgetService` with data saving and callbacks
- [ ] Create Riverpod providers for widget service
- [ ] Initialize service in `main.dart`
- [ ] Call `updateActivityWidget()` when entries change
- [ ] Call `updateAllWidgets()` when activities change
- [ ] Handle deep link navigation from widget

### iOS Side
- [ ] Add Widget Extension target in Xcode
- [ ] Configure App Groups for Runner and Widget Extension
- [ ] Implement `EmberWidget.swift` with SwiftUI view
- [ ] Implement `Provider` for timeline entries
- [ ] Implement Configuration Intent for activity selection
- [ ] Add URL scheme to Info.plist
- [ ] Map all 20 gradient colors in Swift
- [ ] Handle "Activity not found" state
- [ ] Test on physical device

---

## References

- [EMBER_HOME_WIDGETS.md](/EMBER_HOME_WIDGETS.md) - Original feature specification
- [home_widget package](https://pub.dev/packages/home_widget) - Flutter package documentation
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit) - Apple's widget framework
