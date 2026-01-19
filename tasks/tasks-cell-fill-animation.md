# Tasks: Heatmap Cell Fill Animation

## Relevant Files

- `lib/features/habits/presentation/widgets/heatmap_cell.dart` - Week view heatmap cell, needs animation implementation
- `lib/features/habits/presentation/widgets/month_heatmap_cell.dart` - Month view heatmap cell with day numbers, needs animation implementation
- `lib/features/habits/presentation/widgets/mini_month_heatmap.dart` - Grid view mini cells, needs animation in `_buildCell` method
- `lib/features/habits/presentation/widgets/animated_fill_container.dart` - New shared widget for the fill animation logic
- `lib/core/constants/app_durations.dart` - New file for animation duration constants (optional, could add to existing constants)

### Notes

- The animation should use Flutter's built-in animation system (`AnimationController`, `Tween`, `AnimatedBuilder`)
- Consider using `Curves.easeOut` for natural liquid-like deceleration
- The fill effect can be achieved using a `Stack` with a colored container that animates its height via `FractionallySizedBox` or `Align`
- For rapid input handling, use `AnimationController.value` setter to jump to final state when a new animation is triggered before the previous one completes

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Example:
- `- [ ] 1.1 Read file` → `- [x] 1.1 Read file` (after completing)

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks


- [x] 1.0 Create animated heatmap cell base component
  - [x] 1.1 Create new file `lib/features/habits/presentation/widgets/animated_fill_container.dart`
  - [x] 1.2 Create `AnimatedFillContainer` StatefulWidget that accepts: `intensity` (double), `fillColor` (Color), `backgroundColor` (Color), `borderRadius` (BorderRadius), `duration` (Duration), and `child` (Widget?)
  - [x] 1.3 Implement `AnimationController` with configurable duration (default 350ms)
  - [x] 1.4 Store previous intensity value to detect changes and determine animation direction
  - [x] 1.5 Use `didUpdateWidget` to trigger animation when intensity changes
  - [x] 1.6 Build the fill effect using a `Stack` with background color and animated fill overlay

- [x] 2.0 Implement bottom-to-top fill animation
  - [x] 2.1 Use `Tween<double>` to animate from previous intensity to new intensity
  - [x] 2.2 Apply `Curves.easeOut` for natural deceleration effect
  - [x] 2.3 Use `Align` with `alignment: Alignment.bottomCenter` and `FractionallySizedBox` with animated `heightFactor` for the fill effect
  - [x] 2.4 Ensure fill respects the container's border radius using `ClipRRect`
  - [x] 2.5 Handle color transitions when intensity crosses color thresholds (interpolate between colors during animation)
  - [x] 2.6 Test fill animation going up (intensity increase) and down (intensity decrease/drain)

- [x] 3.0 Implement glow animation sequence
  - [x] 3.1 Add `glowColor` (Color?) and `showGlow` (bool) parameters to `AnimatedFillContainer`
  - [x] 3.2 Create secondary `AnimationController` for glow effect (150-200ms duration)
  - [x] 3.3 Trigger glow animation after fill animation completes (use `AnimationController.addStatusListener`)
  - [x] 3.4 Animate glow `BoxShadow` opacity from 0 to target value
  - [x] 3.5 When intensity drops below glow threshold, fade out glow before/during drain animation
  - [x] 3.6 Test glow appears smoothly after fill reaches high intensity

- [x] 4.0 Add rapid input handling (jump to final state)
  - [x] 4.1 In `didUpdateWidget`, check if animation is currently running when new intensity arrives
  - [x] 4.2 If animation is running, call `controller.stop()` and set `controller.value` to complete the previous animation instantly
  - [x] 4.3 Then start the new animation from current visual state to new target intensity
  - [x] 4.4 Test rapid tapping on quick log button - animation should not queue, should jump to final state

- [x] 5.0 Apply animation to all heatmap cell types
  - [x] 5.1 Refactor `HeatmapCell` (week view) to use `AnimatedFillContainer`
  - [x] 5.2 Pass appropriate colors based on theme (light/dark mode) and intensity
  - [x] 5.3 Refactor `MonthHeatmapCell` to use `AnimatedFillContainer`
  - [x] 5.4 Ensure day number text remains visible on top of the fill animation (pass as child)
  - [x] 5.5 Refactor `MiniMonthHeatmap._buildCell` to use `AnimatedFillContainer`
  - [x] 5.6 Verify all three cell types animate correctly with consistent behavior

- [ ] 6.0 Test and verify animations
  - [ ] 6.1 Test week view: tap quick log button, verify fill animation plays
  - [ ] 6.2 Test month view: tap cell to edit entry, verify fill animation plays with visible day numbers
  - [ ] 6.3 Test grid view: tap cell, verify mini cells animate correctly
  - [ ] 6.4 Test intensity decrease: clear an entry, verify drain animation plays (top-to-bottom)
  - [ ] 6.5 Test glow effect: log high intensity entry, verify glow fades in after fill completes
  - [ ] 6.6 Test rapid input: tap quick log rapidly multiple times, verify no animation queuing
  - [ ] 6.7 Test light/dark mode: verify animations look correct in both themes
  - [ ] 6.8 Run `flutter analyze` to ensure no errors or warnings
