import 'dart:ui';

import 'habit_gradients.dart';

/// Predefined color gradients for habits.
abstract class HabitGradientPresets {
  // Ember (Orange) - Default
  static const HabitGradient ember = HabitGradient(
    id: 'ember',
    name: 'Ember',
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
    none: Color(0xFF252529),
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
