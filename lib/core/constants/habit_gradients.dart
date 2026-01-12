import 'dart:ui';

/// Represents a color gradient for habit heat maps.
/// Each gradient has 6 levels: none, low, medium, high, max, and glow.
class HabitGradient {
  final String id;
  final String name;
  final Color none; // 0% - empty/no entry
  final Color low; // 1-25%
  final Color medium; // 26-50%
  final Color high; // 51-75%
  final Color max; // 76-100%
  final Color glow; // Glow effect for top 10%

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
    if (intensity <= 0.25) return Color.lerp(low, medium, intensity / 0.25)!;
    if (intensity <= 0.5) return Color.lerp(medium, high, (intensity - 0.25) / 0.25)!;
    if (intensity <= 0.75) return Color.lerp(high, max, (intensity - 0.5) / 0.25)!;
    return max;
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
