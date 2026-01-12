# Ember - Habit Color Gradients System

## Overview

Users can choose a custom color for each habit. Each color has a full gradient from `none` (empty) through `low`, `medium`, `high`, `max`, and `glow` for heat map intensity visualization.

The default "Ember" orange gradient already exists in `AppColors`. This document defines 9 additional color options and how to integrate them.

---

## Current AppColors State

The app currently has the default Ember gradient in `app_colors.dart`:

```dart
// Ember gradient (heat map intensity)
static const Color emberNone = Color(0xFF1A1A1E);
static const Color emberLow = Color(0xFF3D2417);
static const Color emberMedium = Color(0xFF6B3410);
static const Color emberHigh = Color(0xFFB84D00);
static const Color emberMax = Color(0xFFFF6B1A);
static const Color emberGlow = Color(0xFFFF8C42);
```

---

## Implementation

### 1. Create HabitGradient Class

Create a new file `lib/core/constants/habit_gradients.dart`:

```dart
import 'dart:ui';

/// Represents a color gradient for habit heat maps.
/// Each gradient has 6 levels: none, low, medium, high, max, and glow.
class HabitGradient {
  final String id;
  final String name;
  final Color none;   // 0% - empty/no entry
  final Color low;    // 1-25%
  final Color medium; // 26-50%
  final Color high;   // 51-75%
  final Color max;    // 76-100%
  final Color glow;   // Glow effect for top 10%

  const HabitGradient({
    required this.id,
    required this.name,
    required this.none,
    required this.low,
    required this.medium,
    required this.high,
    required this.max,
    required this.glow,
  });

  /// Get color for a given intensity (0.0 to 1.0) with smooth interpolation.
  Color getColorForIntensity(double intensity) {
    if (intensity <= 0) return none;
    if (intensity <= 0.25) return Color.lerp(none, low, intensity / 0.25)!;
    if (intensity <= 0.5) return Color.lerp(low, medium, (intensity - 0.25) / 0.25)!;
    if (intensity <= 0.75) return Color.lerp(medium, high, (intensity - 0.5) / 0.25)!;
    return Color.lerp(high, max, (intensity - 0.75) / 0.25)!;
  }

  /// Get color and optional glow for intensity.
  /// Glow applies to top 10% (intensity >= 0.9).
  ({Color cellColor, Color? glowColor}) getColorsForIntensity(double intensity) {
    final cellColor = getColorForIntensity(intensity);
    final glowColor = intensity >= 0.9 ? glow : null;
    return (cellColor: cellColor, glowColor: glowColor);
  }

  /// Whether intensity qualifies for glow effect.
  bool shouldGlow(double intensity) => intensity >= 0.9;

  /// The primary display color (max) for UI elements like selectors.
  Color get primaryColor => max;
}
```

### 2. Define All Gradients

Add to the same file or create `lib/core/constants/habit_gradient_presets.dart`:

```dart
import 'dart:ui';

import 'package:ember/core/constants/habit_gradients.dart';

/// Predefined color gradients for habits.
abstract class HabitGradientPresets {
  // Ember (Orange) - Default
  static const HabitGradient ember = HabitGradient(
    id: 'ember',
    name: 'Ember',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D2417),
    medium: Color(0xFF6B3410),
    high: Color(0xFFB84D00),
    max: Color(0xFFFF6B1A),
    glow: Color(0xFFFF8C42),
  );

  // Coral (Soft Red)
  static const HabitGradient coral = HabitGradient(
    id: 'coral',
    name: 'Coral',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D1F1F),
    medium: Color(0xFF6B2F2F),
    high: Color(0xFFB84A4A),
    max: Color(0xFFFF6B6B),
    glow: Color(0xFFFF9494),
  );

  // Sunflower (Yellow)
  static const HabitGradient sunflower = HabitGradient(
    id: 'sunflower',
    name: 'Sunflower',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D3517),
    medium: Color(0xFF6B5A10),
    high: Color(0xFFB89B00),
    max: Color(0xFFFFD93D),
    glow: Color(0xFFFFE566),
  );

  // Mint (Green)
  static const HabitGradient mint = HabitGradient(
    id: 'mint',
    name: 'Mint',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF1E3D24),
    medium: Color(0xFF2E6B3B),
    high: Color(0xFF4AA85A),
    max: Color(0xFF6BCB77),
    glow: Color(0xFF94D99E),
  );

  // Ocean (Blue)
  static const HabitGradient ocean = HabitGradient(
    id: 'ocean',
    name: 'Ocean',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF172A3D),
    medium: Color(0xFF1E4A6B),
    high: Color(0xFF3074B8),
    max: Color(0xFF4D96FF),
    glow: Color(0xFF7AB0FF),
  );

  // Lavender (Purple)
  static const HabitGradient lavender = HabitGradient(
    id: 'lavender',
    name: 'Lavender',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF2D2339),
    medium: Color(0xFF4A3866),
    high: Color(0xFF7B5AA8),
    max: Color(0xFFB085F5),
    glow: Color(0xFFC9A8FF),
  );

  // Rose (Pink)
  static const HabitGradient rose = HabitGradient(
    id: 'rose',
    name: 'Rose',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D2430),
    medium: Color(0xFF6B3B52),
    high: Color(0xFFB8607A),
    max: Color(0xFFFF8FAB),
    glow: Color(0xFFFFB3C6),
  );

  // Teal (Cyan)
  static const HabitGradient teal = HabitGradient(
    id: 'teal',
    name: 'Teal',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF173537),
    medium: Color(0xFF1E5C60),
    high: Color(0xFF30969C),
    max: Color(0xFF4DD0E1),
    glow: Color(0xFF7ADCE8),
  );

  // Sand (Warm Beige)
  static const HabitGradient sand = HabitGradient(
    id: 'sand',
    name: 'Sand',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF352D24),
    medium: Color(0xFF5C4D3A),
    high: Color(0xFF9A7A58),
    max: Color(0xFFD4A574),
    glow: Color(0xFFE2BF9A),
  );

  // Silver (Gray)
  static const HabitGradient silver = HabitGradient(
    id: 'silver',
    name: 'Silver',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF2E2E2E),
    medium: Color(0xFF505050),
    high: Color(0xFF808080),
    max: Color(0xFFB0B0B0),
    glow: Color(0xFFCCCCCC),
  );

  /// All available gradients.
  static const List<HabitGradient> all = [
    ember,
    coral,
    sunflower,
    mint,
    ocean,
    lavender,
    rose,
    teal,
    sand,
    silver,
  ];

  /// Default gradient for new habits.
  static const HabitGradient defaultGradient = ember;

  /// Get gradient by ID, returns default if not found.
  static HabitGradient getById(String? id) {
    if (id == null) return defaultGradient;
    return all.firstWhere(
      (g) => g.id == id,
      orElse: () => defaultGradient,
    );
  }
}
```

---

## Habit Entity Update

Update the `Habit` entity to store the gradient ID:

```dart
class Habit {
  final String id;
  final String name;
  final String? emoji;
  final String unit;
  final String gradientId; // NEW: stores the gradient ID (e.g., 'ember', 'coral')
  final DateTime createdAt;
  final bool isArchived;

  const Habit({
    required this.id,
    required this.name,
    this.emoji,
    required this.unit,
    this.gradientId = 'ember', // Default to ember
    required this.createdAt,
    this.isArchived = false,
  });

  /// Get the HabitGradient for this habit.
  HabitGradient get gradient => HabitGradientPresets.getById(gradientId);
}
```

---

## Usage Examples

### Getting cell color in heat map:

```dart
final habit = // ... get habit
final intensity = // ... calculated intensity (0.0 to 1.0)

final (:cellColor, :glowColor) = habit.gradient.getColorsForIntensity(intensity);

Container(
  decoration: BoxDecoration(
    color: cellColor,
    borderRadius: BorderRadius.circular(4),
    boxShadow: glowColor != null
        ? [
            BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
        : null,
  ),
)
```

### Color picker UI:

```dart
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: HabitGradientPresets.all.map((gradient) {
    final isSelected = selectedGradientId == gradient.id;
    return GestureDetector(
      onTap: () => onGradientSelected(gradient.id),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: gradient.primaryColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
      ),
    );
  }).toList(),
)
```

---

## File Structure

```
lib/core/constants/
├── app_colors.dart           # Keep existing (background, text, semantic colors)
├── habit_gradients.dart      # HabitGradient class
└── habit_gradient_presets.dart # All 10 gradient definitions
```

---

## Summary

| Color | ID | Max Color |
|-------|-----|-----------|
| Ember | `ember` | `#FF6B1A` |
| Coral | `coral` | `#FF6B6B` |
| Sunflower | `sunflower` | `#FFD93D` |
| Mint | `mint` | `#6BCB77` |
| Ocean | `ocean` | `#4D96FF` |
| Lavender | `lavender` | `#B085F5` |
| Rose | `rose` | `#FF8FAB` |
| Teal | `teal` | `#4DD0E1` |
| Sand | `sand` | `#D4A574` |
| Silver | `silver` | `#B0B0B0` |

Each gradient smoothly transitions through 6 levels on the dark background, and the top 10% intensity triggers a glow effect.
