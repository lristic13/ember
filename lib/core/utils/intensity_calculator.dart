import '../constants/intensity_config.dart';

abstract class IntensityCalculator {
  /// Primary method: percentile within rolling window
  /// Returns 0.0 to 1.0
  static double calculatePercentile(double todayValue, List<double> recentValues) {
    if (recentValues.isEmpty || todayValue <= 0) return 0.0;

    final sorted = [...recentValues]..sort();
    final belowCount = sorted.where((v) => v < todayValue).length;
    final equalCount = sorted.where((v) => v == todayValue).length;

    // Percentile rank formula
    return (belowCount + (equalCount / 2)) / sorted.length;
  }

  /// Fallback method: ratio to personal max (for new habits)
  static double calculateFallback(double todayValue, double personalMax) {
    if (personalMax <= 0 || todayValue <= 0) return 0.0;
    return (todayValue / personalMax).clamp(0.0, 1.0);
  }

  /// Main entry point: determines which method to use
  ///
  /// [globalMax] is used for fallback calculations to ensure consistent
  /// intensity across all displayed cells (e.g., day with 1.0 shows dimmer
  /// than day with 6.0, even if 6.0 is the max).
  static double calculateIntensity({
    required double todayValue,
    required List<double> historicalValues,
    double? globalMax,
  }) {
    if (todayValue <= 0) return 0.0;

    // Filter to non-zero values
    final nonZeroValues = historicalValues.where((v) => v > 0).toList();

    if (nonZeroValues.length >= IntensityConfig.minDaysForPercentile) {
      return calculatePercentile(todayValue, nonZeroValues);
    } else {
      // Use global max for consistent visual representation across all cells
      final max = globalMax ?? (nonZeroValues.isEmpty
          ? todayValue
          : nonZeroValues.reduce((a, b) => a > b ? a : b));
      return calculateFallback(todayValue, max);
    }
  }

  /// Check if intensity qualifies for glow effect
  static bool shouldShowGlow(double intensity) {
    return intensity >= IntensityConfig.glowThreshold;
  }
}
