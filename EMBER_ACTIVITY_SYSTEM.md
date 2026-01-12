# Ember - Activity Tracking System

## Overview

This document covers the updated tracking system for Ember:

1. **Rename**: "Habits" are now called "Activities"
2. **Tracking Types**: Users can choose between binary (completion) or measured (quantity) tracking
3. **Intensity Calculation**: Both types use the percentile system for heat map intensity

---

## Terminology Change

| Old | New |
|-----|-----|
| Habit | Activity |
| HabitEntry | ActivityEntry |
| habitId | activityId |
| habits (folder) | activities (folder) |

Update all file names, class names, variable names, and folder structures accordingly.

---

## Tracking Types

```dart
/// How an activity is tracked.
enum TrackingType {
  /// Binary tracking: did it or didn't.
  /// Examples: worked out, meditated, journaled
  completion,

  /// Quantity tracking: measured amount.
  /// Examples: glasses of water, pages read, minutes exercised
  quantity,
}
```

### User-Facing Copy

| TrackingType | Label | Description |
|--------------|-------|-------------|
| `completion` | "Yes / No" | "Track whether you did it" |
| `quantity` | "Measured" | "Track how much you did" |

---

## Updated Entities

### Activity Entity

```dart
class Activity {
  final String id;
  final String name;
  final String? emoji;
  final TrackingType trackingType;
  final String? unit;           // Only used when trackingType == quantity
  final String gradientId;
  final DateTime createdAt;
  final bool isArchived;

  const Activity({
    required this.id,
    required this.name,
    this.emoji,
    required this.trackingType,
    this.unit,
    this.gradientId = 'ember',
    required this.createdAt,
    this.isArchived = false,
  });

  /// Whether this activity tracks quantities.
  bool get isQuantity => trackingType == TrackingType.quantity;

  /// Whether this activity tracks completion only.
  bool get isCompletion => trackingType == TrackingType.completion;
}
```

### ActivityEntry Entity

```dart
class ActivityEntry {
  final String id;
  final String activityId;
  final DateTime date;
  final double value;

  const ActivityEntry({
    required this.id,
    required this.activityId,
    required this.date,
    required this.value,
  });

  /// For completion type: whether the activity was done.
  bool get isCompleted => value > 0;
}
```

### Entry Values by Type

| TrackingType | Value when done | Value when not done |
|--------------|-----------------|---------------------|
| `completion` | `1.0` | `0.0` or no entry |
| `quantity` | Actual amount (e.g., `8.0` glasses) | `0.0` or no entry |

---

## Intensity Calculation

Both tracking types use the **same percentile-based intensity system**. This means:

- For `quantity`: intensity reflects how today compares to your recent amounts
- For `completion`: intensity reflects your consistency/streak strength

### Why Percentile Works for Completion Type

With binary values (0 or 1), the percentile calculation naturally rewards streaks:

- If you completed 6 out of the last 7 days, today's completion puts you in a high percentile
- If you rarely complete, today's completion is more "special" and stands out
- Consistent performers have consistently bright heat maps

### Intensity Calculation Logic

```dart
abstract class IntensityConfig {
  /// Days of data required before switching to percentile method.
  static const int minDaysForPercentile = 14;

  /// Rolling window size for percentile calculation.
  static const int rollingWindowDays = 60;

  /// Percentile threshold for applying glow effect.
  static const double glowThreshold = 0.9;
}

class IntensityCalculator {
  /// Calculate intensity for a given entry value.
  /// Works for both completion (0/1) and quantity (any positive number).
  double calculateIntensity({
    required double todayValue,
    required List<double> recentValues,
  }) {
    // No entry = no intensity
    if (todayValue <= 0) return 0.0;

    // Not enough data: use fallback
    if (recentValues.length < IntensityConfig.minDaysForPercentile) {
      return _calculateFallbackIntensity(todayValue, recentValues);
    }

    // Percentile calculation
    return _calculatePercentileIntensity(todayValue, recentValues);
  }

  double _calculatePercentileIntensity(double todayValue, List<double> values) {
    final sorted = [...values]..sort();
    final belowCount = sorted.where((v) => v < todayValue).length;
    final equalCount = sorted.where((v) => v == todayValue).length;

    // Percentile rank formula
    final percentile = (belowCount + (equalCount / 2)) / sorted.length;

    return percentile.clamp(0.0, 1.0);
  }

  double _calculateFallbackIntensity(double todayValue, List<double> values) {
    if (values.isEmpty) return 1.0; // First entry = full intensity

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return 1.0;

    return (todayValue / maxValue).clamp(0.0, 1.0);
  }
}
```

### Completion Type Intensity Examples

Given last 14 days of completion data: `[1,1,1,0,1,1,0,0,1,1,1,1,0,1]`

- 10 completed days, 4 not completed
- Today you complete → value `1.0`
- Your `1.0` is in the ~71st percentile (10 ones out of 14)
- Intensity ≈ 0.71 → `emberHigh` color

If you had completed 13 out of 14 days:
- Today's `1.0` is in the ~93rd percentile
- Intensity ≈ 0.93 → `emberMax` with glow effect

### Quantity Type Intensity Examples

Given last 14 days of water tracking: `[8,6,10,7,8,5,9,8,7,6,8,10,7,8]`

- Today you drink 10 glasses
- 10 is higher than 12 of the 14 values
- Intensity ≈ 0.86 → `emberMax` color (no glow, under 0.9)

---

## UI Flows

### Activity Creation

```
1. "What do you want to track?"
   → Name input (e.g., "Workout")

2. "How do you want to track it?"
   → [Yes / No]  [Measured]

3. If "Measured" selected:
   "What unit?"
   → Unit input (e.g., "minutes")

4. "Pick a color"
   → Color palette selection

5. Optional: emoji picker
```

### Logging Entry

#### Completion Type

Simple toggle or single tap:

```
┌─────────────────────────────┐
│ 🏋️ Workout                  │
│                             │
│    [ Mark as done ✓ ]       │
│                             │
└─────────────────────────────┘
```

Or just tap the activity card to toggle.

#### Quantity Type

Number input with quick increment:

```
┌─────────────────────────────┐
│ 💧 Water                    │
│                             │
│   [ - ]    8    [ + ]       │
│          glasses            │
│                             │
│       [ Save ]              │
└─────────────────────────────┘
```

---

## Heat Map Display

Both types display the same way—intensity determines cell color/glow.

The only difference is what users see when tapping a cell:

| TrackingType | Cell Tap Detail |
|--------------|-----------------|
| `completion` | "Completed ✓" or "Not done" |
| `quantity` | "8 glasses" or "No entry" |

---

## Database Schema (Hive)

### Activity Model

```dart
@HiveType(typeId: 0)
class ActivityModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? emoji;

  @HiveField(3)
  late int trackingTypeIndex; // 0 = completion, 1 = quantity

  @HiveField(4)
  String? unit;

  @HiveField(5)
  late String gradientId;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late bool isArchived;

  TrackingType get trackingType => TrackingType.values[trackingTypeIndex];
}
```

### ActivityEntry Model

```dart
@HiveType(typeId: 1)
class ActivityEntryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String activityId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late double value;
}
```

---

## File Structure Update

```
lib/features/
├── activities/          # Renamed from habits/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── activity_local_datasource.dart
│   │   ├── models/
│   │   │   ├── activity_model.dart
│   │   │   └── activity_entry_model.dart
│   │   └── repositories/
│   │       └── activity_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── activity.dart
│   │   │   ├── activity_entry.dart
│   │   │   └── tracking_type.dart
│   │   ├── repositories/
│   │   │   └── activity_repository.dart
│   │   └── usecases/
│   │       ├── create_activity.dart
│   │       ├── get_activities.dart
│   │       ├── log_entry.dart
│   │       └── get_entries_for_activity.dart
│   └── presentation/
│       ├── viewmodels/
│       │   └── activity_viewmodel.dart
│       ├── screens/
│       │   ├── activity_list_screen.dart
│       │   ├── activity_detail_screen.dart
│       │   └── create_activity_screen.dart
│       └── widgets/
│           ├── activity_card.dart
│           ├── tracking_type_selector.dart
│           ├── completion_logger.dart
│           └── quantity_logger.dart
```

---

## Summary

| Aspect | Completion | Quantity |
|--------|------------|----------|
| User input | Tap / toggle | Number input |
| Stored value | `1.0` or `0.0` | Any positive number |
| Unit required | No | Yes |
| Intensity calc | Percentile (rewards consistency) | Percentile (rewards high days) |
| Heat map | Same gradient system | Same gradient system |

The percentile system unifies both tracking types—consistency is rewarded for completion, high performance is rewarded for quantity, and both result in beautiful, personalized heat maps.
