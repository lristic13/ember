# PRD: Light/Dark Theme Toggle

## Introduction/Overview

Add a theme toggle feature that allows users to switch between dark and light themes. The current app uses a dark theme exclusively. This feature will introduce a light theme variant and provide users control over their visual preference.

## Goals

1. Implement a complete light theme color palette that complements the existing dark theme
2. Allow users to toggle between themes with a single tap
3. Persist theme preference across app sessions
4. Maintain visual consistency and readability in both themes

## User Stories

1. **As a user**, I want to switch to a light theme so I can use the app comfortably in bright environments.
2. **As a user**, I want my theme preference saved so I don't have to set it every time I open the app.
3. **As a user**, I want to easily access the theme toggle so I can quickly switch based on my environment.

## Functional Requirements

1. **FR-1:** The app must display a theme toggle icon button on the left side of the app bar on the home screen.
2. **FR-2:** The icon must display a sun icon when in dark mode (indicating "switch to light") and a moon icon when in light mode (indicating "switch to dark").
3. **FR-3:** Tapping the icon must instantly switch the entire app's theme (no animation).
4. **FR-4:** The selected theme must be persisted to local storage using SharedPreferences or Hive.
5. **FR-5:** On app launch, the app must load and apply the user's previously selected theme.
6. **FR-6:** The default theme for new users (no saved preference) must be dark.
7. **FR-7:** All screens must properly respond to theme changes (colors, backgrounds, text).
8. **FR-8:** The light theme must include appropriate colors for:
   - Background (primary and surface)
   - Text (primary and secondary)
   - Cards and containers
   - App bar
   - Buttons and interactive elements
   - Error states
   - Heatmap cells (ensure gradient visibility on light backgrounds)

## Non-Goals (Out of Scope)

- System theme detection/following (user manually controls theme)
- Animated theme transitions
- Custom/additional themes beyond light and dark
- Per-screen theme settings
- Scheduled theme switching (e.g., based on time of day)

## Design Considerations

### Icon Placement
- Left side of app bar on home screen
- Use `Icons.light_mode` (sun) when in dark mode
- Use `Icons.dark_mode` (moon) when in light mode

### Light Theme Color Palette
The light theme should:
- Use light backgrounds (#FAFAFA or similar)
- Use dark text for readability (#1A1A1E or similar)
- Maintain the ember/orange accent colors for brand consistency
- Ensure heatmap gradients remain visible and distinct
- Use subtle shadows/borders for card definition (since dark cards won't stand out)

### Affected Components
- App bar backgrounds (remove glass blur opacity adjustments for light theme, or adjust)
- Card backgrounds
- Bottom navigation/button area
- All text colors
- Empty state illustrations/icons
- Dialog/modal backgrounds
- Input field styling

## Technical Considerations

1. **State Management:** Use Riverpod for theme state (ThemeNotifier)
2. **Persistence:** Use existing Hive setup or SharedPreferences for storing theme preference
3. **Theme Data:** Create `AppTheme` class with `lightTheme` and `darkTheme` ThemeData objects
4. **Color Constants:** Extend `AppColors` to support both themes or create separate light/dark color sets
5. **Material App:** Wrap theme switching at the `MaterialApp` level using `theme` and `darkTheme` properties with `themeMode`

### Implementation Approach
```
lib/
  core/
    theme/
      app_theme.dart          # ThemeData definitions
      theme_provider.dart     # Riverpod provider for theme state
    constants/
      app_colors.dart         # Update with light theme colors
```

## Success Metrics

1. Theme toggle is accessible within 1 tap from home screen
2. Theme preference persists correctly across app restarts
3. All screens render correctly in both themes with no visual bugs
4. No performance impact when switching themes

## Design Decisions

1. **Heatmap gradients:** Keep same gradient colors - they will pop nicely on light backgrounds
2. **Glass blur effects:** Keep glass blur with adjusted opacity for light theme
3. **Fire emoji shadow:** Keep shadow for visual consistency across both themes
