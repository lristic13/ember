# Tasks: Shareable Heat Map Images

## Relevant Files

- `lib/features/share/presentation/widgets/share_card.dart` - Main share card widget container
- `lib/features/share/presentation/widgets/share_card_heat_map.dart` - Year heat map grid for share card
- `lib/features/share/presentation/widgets/share_card_stats.dart` - Statistics display (days logged, streak)
- `lib/features/share/presentation/widgets/share_card_branding.dart` - Ember branding footer
- `lib/features/share/presentation/widgets/share_preview_dialog.dart` - Preview dialog before sharing
- `lib/features/share/presentation/utils/heat_map_image_generator.dart` - Renders widget to PNG
- `lib/features/share/domain/usecases/share_heat_map.dart` - Use case for sharing flow
- `lib/features/habits/presentation/widgets/year_heatmap_content.dart` - Add share button to year view
- `lib/features/habits/presentation/screens/habit_detail_screen.dart` - Add share button to app bar

### Notes

- Requires adding `share_plus` and `path_provider` packages to pubspec.yaml
- Share card is rendered off-screen, not displayed in the UI directly
- Image generation uses `RepaintBoundary.toImage()` with 3x pixel ratio for quality

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [x] 1.0 Add required dependencies
  - [x] 1.1 Add `share_plus: ^10.0.0` to pubspec.yaml dependencies
  - [x] 1.2 Add `path_provider: ^2.1.0` to pubspec.yaml dependencies
  - [x] 1.3 Run `flutter pub get` to install packages
  - [x] 1.4 Verify packages are installed correctly by checking pubspec.lock

- [x] 2.0 Create share card widgets
  - [x] 2.1 Create directory structure: `lib/features/share/presentation/widgets/`
  - [x] 2.2 Create `share_card_branding.dart` - "Made with Ember" footer widget with app icon
  - [x] 2.3 Create `share_card_stats.dart` - displays "Days logged" and "Longest streak" statistics
  - [x] 2.4 Create `share_card_heat_map.dart` - renders full year heat map grid (53 weeks × 7 days)
  - [x] 2.5 Create `share_card.dart` - main container widget (1080×1920) combining header, heat map, stats, and branding
  - [x] 2.6 Ensure share card uses dark background regardless of app theme
  - [x] 2.7 Ensure heat map cells use the activity's gradient colors with glow effects for high intensity

- [x] 3.0 Create image generator utility
  - [x] 3.1 Create directory: `lib/features/share/presentation/utils/`
  - [x] 3.2 Create `heat_map_image_generator.dart` with static `generate()` method
  - [x] 3.3 Implement widget-to-image rendering using `RenderRepaintBoundary.toImage()` with 3x pixel ratio
  - [x] 3.4 Implement PNG byte conversion and temp file saving using `path_provider`
  - [x] 3.5 Return generated file path for use with share_plus

- [x] 4.0 Create share preview dialog and use case
  - [x] 4.1 Create `share_preview_dialog.dart` widget showing generated image with Cancel/Share buttons
  - [x] 4.2 Add year picker to preview dialog (dropdown or scrollable list of years with data)
  - [x] 4.3 Create directory: `lib/features/share/domain/usecases/`
  - [x] 4.4 Create `share_heat_map.dart` use case that orchestrates the sharing flow
  - [x] 4.5 Create Riverpod provider for the share use case
  - [x] 4.6 Implement loading state while generating image
  - [x] 4.7 Implement error handling with user-friendly error messages

- [x] 5.0 Add share button to activity detail screen
  - [x] 5.1 Locate the activity detail screen (likely `habit_detail_screen.dart` or similar)
  - [x] 5.2 Add share icon button to the app bar actions
  - [x] 5.3 Implement share button tap handler that shows preview dialog
  - [x] 5.4 Query available years with data for the year picker
  - [x] 5.5 Pass activity data and entries to the share flow

- [x] 6.0 Add share button to year heatmap view
  - [x] 6.1 Locate the year heatmap view widget (`year_heatmap_content.dart` or similar)
  - [x] 6.2 Add share icon button (in header or as floating action)
  - [x] 6.3 Implement share button tap handler that shows preview dialog
  - [x] 6.4 Use currently displayed year as default selection in preview

- [ ] 7.0 Test and verify sharing functionality
  - [ ] 7.1 Test share button appears in activity detail screen
  - [ ] 7.2 Test share button appears in year heatmap view
  - [ ] 7.3 Test year picker shows only years with data
  - [ ] 7.4 Test preview dialog displays generated image correctly
  - [ ] 7.5 Test Cancel button dismisses dialog without sharing
  - [ ] 7.6 Test Share button opens native share sheet with image
  - [ ] 7.7 Test shared image quality and content (heat map, stats, branding visible)
  - [ ] 7.8 Test loading indicator appears during image generation
  - [ ] 7.9 Test error handling when image generation fails
  - [x] 7.10 Run `flutter analyze` to ensure no errors or warnings
