# PRD: Shareable Heat Map Images

## Introduction/Overview

This feature allows users to share beautiful images of their activity heat maps to social media, messages, and other apps. When a user taps the share button, the app generates a visually appealing image containing their heat map, key statistics, and Ember branding. This serves as both a personal achievement showcase and organic marketing for the app.

## Goals

1. Enable users to easily share their progress visually
2. Create shareable images that look polished and professional
3. Include subtle Ember branding for organic app discovery
4. Support sharing any year the user has tracked data for
5. Provide a preview before sharing so users know what they're posting

## User Stories

1. **As a user**, I want to share my yearly heat map so I can showcase my consistency and progress to friends and followers.

2. **As a user**, I want to preview the image before sharing so I can make sure it looks good and choose the right year.

3. **As a user**, I want to share heat maps from previous years so I can do "year in review" posts or compare my progress over time.

4. **As a user**, I want the shared image to look professional and visually appealing so I'm proud to post it on social media.

## Functional Requirements

1. **Share Button Placement**: The share button must be accessible from:
   - Activity detail screen header (app bar)
   - Year heatmap view screen

2. **Image Format**: The generated image must be in Story format (1080 × 1920 pixels) optimized for Instagram/Facebook stories.

3. **Year Selection**: Users must be able to select which year to share from a list of years they have data for.

4. **Preview Dialog**: Before sharing, the app must display a preview dialog showing:
   - The generated image
   - A "Cancel" button to abort
   - A "Share" button to proceed to the native share sheet

5. **Share Card Content**: The generated image must include:
   - Activity name and emoji (if set)
   - Selected year
   - Full year heat map grid with appropriate colors and glow effects
   - Statistics: "Days logged" count and "Longest streak"
   - Ember branding footer ("Made with Ember" + app icon)

6. **Dark Background**: The share card must always use a dark background regardless of the app's current theme (dark backgrounds perform better on social media).

7. **Loading State**: While generating the image, the app must show a loading indicator to provide feedback.

8. **Native Share Sheet**: After the user confirms in the preview, the app must open the native OS share sheet with:
   - The generated PNG image
   - Default share text: "My {activity name} journey in {year} 🔥\n\nTracked with Ember"

9. **Color Consistency**: The heat map cells in the share card must use the same gradient colors as the in-app heat map for the activity.

10. **Glow Effect**: High-intensity cells (≥ 0.9) must display the glow effect in the share card, matching the in-app appearance.

11. **Error Handling**: If image generation fails, the app must display an error message and allow the user to retry.

## Non-Goals (Out of Scope)

- Multiple image formats (Square, Wide) - Story format only for initial release
- Customizable backgrounds or themes for the share card
- Editing statistics or hiding certain data before sharing
- Direct posting to specific social platforms (uses native share sheet only)
- Sharing month views or week views (year view only)
- Adding custom text or annotations to the image
- Video/animated share formats

## Design Considerations

- **Share Card Layout** (top to bottom):
  1. Top padding (safe area)
  2. Activity header (emoji + name + year)
  3. Year heat map grid (53 weeks × 7 days)
  4. Statistics section (days logged, longest streak)
  5. Spacer
  6. Branding footer ("Made with Ember")
  7. Bottom padding

- **Typography**: Use clear, readable fonts. Activity name should be prominent (large, bold). Stats should be secondary but legible.

- **Colors**:
  - Dark background (near-black, e.g., `#0D0D0D` or app's dark theme background)
  - White/light text for readability
  - Heat map uses activity's gradient colors
  - Stats values use the gradient's primary/max color for accent

- **Branding**: Subtle but present. Small app icon + "Made with Ember" text. Not overwhelming.

## Technical Considerations

1. **Required Packages**:
   ```yaml
   dependencies:
     share_plus: ^10.0.0
     path_provider: ^2.1.0
   ```

2. **Image Generation Approach**:
   - Build a `ShareCard` widget (not rendered on screen)
   - Wrap in `RepaintBoundary`
   - Use `RenderRepaintBoundary.toImage()` to capture as image
   - Convert to PNG bytes
   - Write to temporary file
   - Pass file path to `share_plus`

3. **File Structure**:
   ```
   lib/features/share/
   ├── domain/
   │   └── usecases/
   │       └── share_heat_map.dart
   └── presentation/
       ├── widgets/
       │   ├── share_card.dart
       │   ├── share_card_heat_map.dart
       │   ├── share_card_stats.dart
       │   ├── share_card_branding.dart
       │   └── share_preview_dialog.dart
       └── utils/
           └── heat_map_image_generator.dart
   ```

4. **Performance**: Image generation should happen off the main thread where possible. Show loading indicator during generation (typically 1-2 seconds).

5. **Temporary Files**: Generated images are stored in the app's temp directory and can be cleaned up by the OS. No manual cleanup required.

6. **Year Data**: Query the entry repository to determine which years have data for the year picker.

## Success Metrics

1. Share feature is accessible and functional from both specified locations
2. Generated images render correctly with all required elements
3. Preview displays accurately before sharing
4. Native share sheet opens successfully with image and text
5. Image quality is sharp and suitable for social media (3x pixel ratio)

## Open Questions

None - all questions resolved.
