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

  // Ruby (Deep Red)
  static const HabitGradient ruby = HabitGradient(
    id: 'ruby',
    name: 'Ruby',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D1515),
    medium: Color(0xFF6B2222),
    high: Color(0xFFB83A3A),
    max: Color(0xFFE53935),
    glow: Color(0xFFFF6659),
  );

  // Peach (Soft Orange)
  static const HabitGradient peach = HabitGradient(
    id: 'peach',
    name: 'Peach',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D2A22),
    medium: Color(0xFF6B4A3A),
    high: Color(0xFFB87A62),
    max: Color(0xFFFFAB91),
    glow: Color(0xFFFFC4B0),
  );

  // Lime (Vibrant Green)
  static const HabitGradient lime = HabitGradient(
    id: 'lime',
    name: 'Lime',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF2A3D17),
    medium: Color(0xFF4A6B22),
    high: Color(0xFF7AB830),
    max: Color(0xFFAEEA00),
    glow: Color(0xFFC6FF41),
  );

  // Sky (Light Blue)
  static const HabitGradient sky = HabitGradient(
    id: 'sky',
    name: 'Sky',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF17303D),
    medium: Color(0xFF22526B),
    high: Color(0xFF4A90B8),
    max: Color(0xFF81D4FA),
    glow: Color(0xFFB3E5FC),
  );

  // Violet (Deep Purple)
  static const HabitGradient violet = HabitGradient(
    id: 'violet',
    name: 'Violet',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF1F1739),
    medium: Color(0xFF352566),
    high: Color(0xFF5A3DB8),
    max: Color(0xFF7C4DFF),
    glow: Color(0xFFA47FFF),
  );

  // Magenta (Hot Pink)
  static const HabitGradient magenta = HabitGradient(
    id: 'magenta',
    name: 'Magenta',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D1728),
    medium: Color(0xFF6B2245),
    high: Color(0xFFB83070),
    max: Color(0xFFFF4081),
    glow: Color(0xFFFF79A3),
  );

  // Amber (Golden)
  static const HabitGradient amber = HabitGradient(
    id: 'amber',
    name: 'Amber',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF3D2E0F),
    medium: Color(0xFF6B5010),
    high: Color(0xFFB88A00),
    max: Color(0xFFFFB300),
    glow: Color(0xFFFFC940),
  );

  // Sage (Muted Green)
  static const HabitGradient sage = HabitGradient(
    id: 'sage',
    name: 'Sage',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF1E2E20),
    medium: Color(0xFF3A5C3E),
    high: Color(0xFF6B9970),
    max: Color(0xFFA5D6A7),
    glow: Color(0xFFC8E6C9),
  );

  // Slate (Blue Gray)
  static const HabitGradient slate = HabitGradient(
    id: 'slate',
    name: 'Slate',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF1E2528),
    medium: Color(0xFF3D4F56),
    high: Color(0xFF607D8B),
    max: Color(0xFF90A4AE),
    glow: Color(0xFFB0BEC5),
  );

  // Copper (Metallic Warm)
  static const HabitGradient copper = HabitGradient(
    id: 'copper',
    name: 'Copper',
    none: Color(0xFF1A1A1E),
    low: Color(0xFF2E2117),
    medium: Color(0xFF5C3D26),
    high: Color(0xFF8B5E34),
    max: Color(0xFFB87333),
    glow: Color(0xFFD4945A),
  );

  /// All available gradients.
  static const List<HabitGradient> all = [
    ruby,
    coral,
    ember,
    peach,
    amber,
    sunflower,
    lime,
    mint,
    sage,
    teal,
    sky,
    ocean,
    violet,
    lavender,
    magenta,
    rose,
    copper,
    sand,
    slate,
    silver,
  ];

  /// Default gradient for new habits.
  static const HabitGradient defaultGradient = ember;

  /// Get gradient by ID, returns default if not found.
  static HabitGradient getById(String? id) {
    if (id == null) return defaultGradient;
    return all.firstWhere((g) => g.id == id, orElse: () => defaultGradient);
  }
}
