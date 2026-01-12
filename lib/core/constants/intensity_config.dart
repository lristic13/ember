abstract class IntensityConfig {
  /// Days of data required before switching to percentile method
  static const int minDaysForPercentile = 14;

  /// Rolling window size for percentile calculation
  static const int rollingWindowDays = 60;

  /// Percentile threshold for applying glow effect
  static const double glowThreshold = 0.9;
}
