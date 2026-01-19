# PRD: Heatmap Cell Fill Animation

## Introduction/Overview

This feature adds a satisfying visual animation to heatmap cells when their intensity changes. When a user logs an entry (via the quick log button or entry editor), the cell will animate with a "liquid fill" effect from bottom to top, providing visual feedback that reinforces the action. This creates a more polished, engaging user experience.

## Goals

1. Provide immediate visual feedback when users log entries
2. Make the app feel more responsive and polished
3. Create a satisfying "reward" feeling when completing habits/activities
4. Maintain smooth performance (60fps) during animations

## User Stories

1. **As a user**, when I tap the quick log button, I want to see the corresponding heatmap cell fill up with color so I get satisfying visual confirmation of my action.

2. **As a user**, when I clear an entry, I want to see the cell empty out (reverse animation) so I understand the entry was removed.

3. **As a user**, when I log a high-intensity entry, I want to see the glow effect fade in after the fill completes, creating a layered, polished animation sequence.

## Functional Requirements

1. **Fill Animation Direction**: The cell must animate from bottom-to-top, like liquid filling a container.

2. **Bidirectional Animation**:
   - When intensity increases: animate fill upward
   - When intensity decreases: animate fill downward (reverse/drain effect)

3. **Animation Duration**: The fill animation must complete in 300-400ms (target: 350ms).

4. **Glow Animation Sequence**: For cells that reach the glow threshold (intensity >= 0.9):
   - First: complete the fill animation
   - Then: fade/pulse in the glow effect (additional 150-200ms)

5. **Animation Trigger**: The animation must trigger when:
   - Quick log button is pressed
   - Entry is saved/updated via the entry editor bottom sheet
   - Entry is cleared/deleted

6. **Intensity-Based Fill Level**: The fill height must correspond to the intensity value:
   - 0% intensity = empty (no fill)
   - 50% intensity = half filled
   - 100% intensity = fully filled

7. **Color Transition**: If the color changes during the animation (e.g., moving from low to high intensity bracket), the color should smoothly transition alongside the fill.

8. **Performance**: Animation must maintain 60fps and not cause jank or frame drops.

9. **Affected Components**: The animation should apply to all heatmap cell types:
   - `HeatmapCell` (week view)
   - `MonthHeatmapCell` (month view)
   - `MiniMonthHeatmap` cells (grid view)

10. **Rapid Input Handling**: If the user taps the quick log button multiple times rapidly, the animation should jump to the final state rather than queuing multiple animations. This ensures responsiveness.

11. **Day Number Visibility**: For month view cells that display day numbers, the numbers must remain visible throughout the animation (no fading in/out).

## Non-Goals (Out of Scope)

- Sound effects or haptic feedback (may be added later)
- Animation when scrolling through historical data
- Animation on initial load/app startup
- Customizable animation settings by user
- Animation for the "today" border indicator
- Ripple or splash effects at the fill line

## Design Considerations

- The fill effect should use the gradient colors defined in `HabitGradient`
- The animation should respect the cell's border radius (rounded corners)
- The empty portion of the cell should show the appropriate background color (theme-aware for light/dark mode)
- Consider using `ClipRRect` or `ShaderMask` for the fill clipping effect
- The glow effect should use the existing `boxShadow` approach but animate its opacity/spread

## Technical Considerations

1. **Animation Approach Options**:
   - Use `AnimatedContainer` with `alignment` for simple fill effect
   - Use `Stack` with animated `Positioned` or `FractionallySizedBox`
   - Use custom `CustomPainter` for more control over the fill shape

2. **State Management**:
   - Cells need to track their previous intensity to animate from old → new value
   - Consider using `AnimationController` in a `StatefulWidget` or `ConsumerStatefulWidget`

3. **Dependencies**:
   - May leverage existing Flutter animation classes (`Tween`, `CurvedAnimation`)
   - Consider `Curves.easeOut` for natural liquid-like deceleration

4. **Files to Modify**:
   - `lib/features/habits/presentation/widgets/heatmap_cell.dart`
   - `lib/features/habits/presentation/widgets/month_heatmap_cell.dart`
   - `lib/features/habits/presentation/widgets/mini_month_heatmap.dart`

## Success Metrics

1. Animation plays correctly on 100% of quick log actions
2. Animation maintains 60fps (no dropped frames)
3. Both fill and drain animations work correctly
4. Glow effect animates in sequence after fill completes

## Open Questions

None - all questions resolved.
