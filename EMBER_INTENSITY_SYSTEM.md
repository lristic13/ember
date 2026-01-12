# Ember - Heat Map Intensity System

## Overview

Ember uses a **goal-free tracking approach**. Users log habits casually without binding targets. Heat map intensity is calculated relative to the user's own historical patterns, not arbitrary goals.

This keeps the app motivational without pressure—your heat map reflects *your* journey, not some external standard.

---

## Core Principle

> Intensity = How does today compare to your recent self?

A user who logs 3 glasses of water daily should have an equally vibrant heat map as someone who logs 12—it's about personal consistency and patterns, not absolute numbers.

---

## Intensity Calculation

### Primary Method: Percentile Within Rolling Window

After the user has **14+ days of data** for a habit:

1. Take the last **60 days** of entries (or all entries if < 60 days but > 14 days)
2. Calculate where today's value falls as a percentile within that distribution
3. Map percentile to intensity

```dart
double calculateIntensity(double todayValue, List<double> recentValues) {
  if (recentValues.isEmpty) return 0.0;
  
  final sorted = [...recentValues]..sort();
  final belowCount = sorted.where((v) => v < todayValue).length;
  final equalCount = sorted.where((v) => v == todayValue).length;
  
  // Percentile rank formula
  final percentile = (belowCount + (equalCount / 2)) / sorted.length;
  
  return percentile; // 0.0 to 1.0
}
```

### Intensity Mapping

| Percentile | Intensity | Visual |
|------------|-----------|--------|
| 0-10% | 0.0 - 0.1 | `emberNone` - barely visible |
| 10-25% | 0.1 - 0.25 | `emberLow` - dim glow |
| 25-50% | 0.25 - 0.5 | `emberMedium` - moderate |
| 50-75% | 0.5 - 0.75 | `emberHigh` - bright |
| 75-90% | 0.75 - 0.9 | `emberMax` - very bright |
| 90-100% | 0.9 - 1.0 | `emberMax` + glow effect |

### Fallback Method: Personal Best (for new habits)

For habits with **< 14 days of data**, use simple ratio to personal max:

```dart
double calculateIntensityFallback(double todayValue, double personalMax) {
  if (personalMax <= 0) return 0.0;
  return (todayValue / personalMax).clamp(0.0, 1.0);
}
```

This ensures new habits still have meaningful heat maps from day one.

---

## Implementation Details

### Rolling Window Configuration

```dart
abstract class IntensityConfig {
  /// Days of data required before switching to percentile method
  static const int minDaysForPercentile = 14;
  
  /// Rolling window size for percentile calculation
  static const int rollingWindowDays = 60;
  
  /// Percentile threshold for applying glow effect
  static const double glowThreshold = 0.9;
}
```

### Data Fetching

When calculating intensity for a heat map cell:

1. Query entries for the habit within the rolling window
2. Extract non-zero values (days with entries)
3. Apply appropriate calculation method based on data availability

```dart
Future<double> getIntensityForDate(String habitId, DateTime date) async {
  final windowStart = date.subtract(Duration(days: IntensityConfig.rollingWindowDays));
  
  final entries = await _entryRepository.getEntriesInRange(
    habitId: habitId,
    start: windowStart,
    end: date,
  );
  
  final values = entries.map((e) => e.value).where((v) => v > 0).toList();
  final todayEntry = entries.firstWhereOrNull((e) => e.date.isSameDay(date));
  final todayValue = todayEntry?.value ?? 0;
  
  if (todayValue == 0) return 0.0;
  
  if (values.length >= IntensityConfig.minDaysForPercentile) {
    return calculateIntensity(todayValue, values);
  } else {
    final max = values.reduce((a, b) => a > b ? a : b);
    return calculateIntensityFallback(todayValue, max);
  }
}
```

---

## Edge Cases

### Zero entries
- No entry for a day = 0 intensity (empty cell)
- Entry with value 0 = 0 intensity (user explicitly logged zero)

### Single entry only
- First ever entry = 100% intensity (it's your best by default)
- Encourages the user right from the start

### All entries identical
- Every day at percentile 50% = medium intensity for all
- This is correct—no variance means no standout days

### Outliers
- One massive outlier day won't skew everything
- Percentile method naturally handles this—that day is just 100%, others remain relative to each other

---

## Visual Application

### Heat Map Cell Color

```dart
Color getColorForIntensity(double intensity) {
  if (intensity <= 0) return AppColors.emberNone;
  if (intensity <= 0.25) return Color.lerp(AppColors.emberNone, AppColors.emberLow, intensity / 0.25)!;
  if (intensity <= 0.5) return Color.lerp(AppColors.emberLow, AppColors.emberMedium, (intensity - 0.25) / 0.25)!;
  if (intensity <= 0.75) return Color.lerp(AppColors.emberMedium, AppColors.emberHigh, (intensity - 0.5) / 0.25)!;
  return Color.lerp(AppColors.emberHigh, AppColors.emberMax, (intensity - 0.75) / 0.25)!;
}
```

### Glow Effect

Apply glow only to high-percentile cells:

```dart
BoxDecoration getCellDecoration(double intensity) {
  final color = getColorForIntensity(intensity);
  
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppDimensions.heatMapCellRadius),
    boxShadow: intensity >= IntensityConfig.glowThreshold
        ? [
            BoxShadow(
              color: AppColors.emberGlow.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
        : null,
  );
}
```

---

## Data Model Update

Since we removed fixed goals, the `Habit` entity simplifies:

```dart
class Habit {
  final String id;
  final String name;
  final String? emoji;
  final String unit;           // "glasses", "pages", "minutes", etc.
  // REMOVED: final double dailyGoal;
  final Color? color;
  final DateTime createdAt;
  final bool isArchived;
}
```

The `HabitEntry` entity remains unchanged:

```dart
class HabitEntry {
  final String id;
  final String habitId;
  final DateTime date;
  final double value;
}
```

---

## Summary

- **No goals** — users log what they want, when they want
- **Percentile-based intensity** — your heat map reflects your own patterns
- **14-day threshold** — new habits use personal-best ratio until enough data exists
- **60-day rolling window** — recent behavior matters most, adapts over time
- **Glow effect** — reserved for top 10% days, makes standout moments feel special

This approach keeps Ember motivational without being judgmental. Every user's heat map tells their unique story.
