# Tasks: Light/Dark Theme Toggle

## Relevant Files

### New Files
- `lib/core/theme/theme_provider.dart` - Riverpod provider for theme state management and persistence
- `lib/core/theme/app_colors_light.dart` - Light theme color definitions

### Modified Files
- `lib/core/theme/app_theme.dart` - Add lightTheme getter alongside existing darkTheme
- `lib/core/constants/app_colors.dart` - May need theme-aware color helpers
- `lib/main.dart` - Integrate theme provider with MaterialApp
- `lib/features/habits/presentation/screens/habits_screen.dart` - Add theme toggle button to app bar
- `lib/features/habits/presentation/screens/habit_details_screen.dart` - Ensure theme-aware colors
- `lib/features/habits/presentation/screens/create_habit_screen.dart` - Ensure theme-aware colors
- `lib/features/habits/presentation/screens/edit_habit_screen.dart` - Ensure theme-aware colors
- `lib/features/habits/presentation/screens/year_heatmap_screen.dart` - Ensure theme-aware colors
- `lib/features/insights/presentation/screens/insights_screen.dart` - Ensure theme-aware colors

### Notes
- Use `flutter pub run build_runner build` after adding Riverpod annotations
- Theme preference will be stored in Hive (existing setup) for consistency

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [x] 1.0 Create theme infrastructure (providers and persistence)
  - [x] 1.1 Create `lib/core/theme/theme_provider.dart` with ThemeMode enum (light/dark)
  - [x] 1.2 Create Riverpod StateNotifier for theme state
  - [x] 1.3 Add Hive box for theme preference storage (or use existing settings box)
  - [x] 1.4 Implement loadTheme() to read saved preference on startup
  - [x] 1.5 Implement toggleTheme() to switch and persist theme
  - [x] 1.6 Run build_runner to generate provider code

- [x] 2.0 Define light theme color palette
  - [x] 2.1 Create `lib/core/theme/app_colors_light.dart` with light theme colors
  - [x] 2.2 Define background colors (light backgrounds ~#FAFAFA)
  - [x] 2.3 Define surface colors for cards/containers
  - [x] 2.4 Define text colors (dark text for readability ~#1A1A1E)
  - [x] 2.5 Keep accent color (ember orange) consistent with dark theme
  - [x] 2.6 Define semantic colors (error, success) appropriate for light backgrounds

- [x] 3.0 Create ThemeData definitions for light and dark themes
  - [x] 3.1 Update `lib/core/theme/app_theme.dart` to add lightTheme getter
  - [x] 3.2 Configure light theme scaffoldBackgroundColor
  - [x] 3.3 Configure light theme ColorScheme.light()
  - [x] 3.4 Configure light theme appBarTheme with appropriate systemOverlayStyle
  - [x] 3.5 Configure light theme cardTheme with subtle borders/shadows
  - [x] 3.6 Configure light theme inputDecorationTheme
  - [x] 3.7 Configure light theme button themes (elevated, text, outlined)
  - [x] 3.8 Configure light theme bottomSheetTheme and dialogTheme
  - [x] 3.9 Configure light theme snackBarTheme and dividerTheme

- [x] 4.0 Integrate theme switching at MaterialApp level
  - [x] 4.1 Update `lib/main.dart` to make EmberApp a ConsumerWidget
  - [x] 4.2 Watch theme provider in build method
  - [x] 4.3 Set MaterialApp.router theme property to AppTheme.lightTheme
  - [x] 4.4 Set MaterialApp.router darkTheme property to AppTheme.darkTheme
  - [x] 4.5 Set MaterialApp.router themeMode based on provider state
  - [x] 4.6 Initialize theme provider on app startup (load saved preference)

- [x] 5.0 Add theme toggle button to home screen app bar
  - [x] 5.1 Update `habits_screen.dart` to add IconButton on left side of app bar
  - [x] 5.2 Watch theme provider to determine current theme
  - [x] 5.3 Show Icons.light_mode (sun) when in dark mode
  - [x] 5.4 Show Icons.dark_mode (moon) when in light mode
  - [x] 5.5 Call toggleTheme() on button press

- [x] 6.0 Update all screens to use theme-aware colors
  - [x] 6.1 Update `habits_screen.dart` glass blur background to use theme colors
  - [x] 6.2 Update `habit_details_screen.dart` to use Theme.of(context) colors
  - [x] 6.3 Update `create_habit_screen.dart` to use theme-aware colors
  - [x] 6.4 Update `edit_habit_screen.dart` to use theme-aware colors
  - [x] 6.5 Update `year_heatmap_screen.dart` to use theme-aware colors
  - [x] 6.6 Update `insights_screen.dart` to use theme-aware colors
  - [x] 6.7 Review and update any widgets using hardcoded AppColors for backgrounds/text
  - [x] 6.8 Verify glass blur effect opacity works well in both themes
