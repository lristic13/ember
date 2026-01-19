# Ember - Mock Data Generator for Screenshots

## Purpose

Generate realistic mock data to fill up heat maps for App Store screenshots. This is temporary code—remove before release.

---

## Requirements

- Fill the entire year 2025 (January 1 to today) with entries
- Generate data for all existing activities
- Make it look realistic (natural streaks and gaps, not random noise)
- Support both completion and quantity tracking types
- Easy to trigger (debug button) and easy to remove

---

## Implementation

### 1. Create Mock Data Generator

Create a new file: `lib/core/utils/mock_data_generator.dart`

```dart
import 'dart:math';

import 'package:uuid/uuid.dart';

// Adjust imports to match your project structure
import 'package:ember/features/activities/domain/entities/activity.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';
import 'package:ember/features/activities/domain/repositories/activity_repository.dart';
import 'package:ember/features/activities/domain/repositories/entry_repository.dart';

class MockDataGenerator {
  final ActivityRepository _activityRepository;
  final EntryRepository _entryRepository;
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  MockDataGenerator({
    required ActivityRepository activityRepository,
    required EntryRepository entryRepository,
  })  : _activityRepository = activityRepository,
        _entryRepository = entryRepository;

  /// Generates realistic mock data for all activities from Jan 1, 2025 to today.
  /// Creates natural-looking streaks and gaps.
  Future<void> generate() async {
    final activities = await _activityRepository.getAll();
    
    if (activities.isEmpty) {
      throw Exception('No activities found. Create some activities first.');
    }

    final startDate = DateTime(2025, 1, 1);
    final endDate = DateTime.now();

    for (final activity in activities) {
      await _generateEntriesForActivity(
        activity: activity,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  Future<void> _generateEntriesForActivity({
    required Activity activity,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Base probability of showing up (varies per activity for variety)
    double baseShowUpRate = 0.5 + (_random.nextDouble() * 0.35); // 0.5 to 0.85
    double showUpProbability = baseShowUpRate;

    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      
      final showedUp = _random.nextDouble() < showUpProbability;

      if (showedUp) {
        // Streak continues - slightly increase probability
        showUpProbability = (showUpProbability + 0.05).clamp(0.0, 0.95);

        final entry = ActivityEntry(
          id: _uuid.v4(),
          activityId: activity.id,
          date: DateTime(date.year, date.month, date.day),
          value: _generateValue(activity),
        );

        await _entryRepository.save(entry);
      } else {
        // Missed day - decrease probability (simulates falling off)
        showUpProbability = (showUpProbability - 0.1).clamp(0.3, 0.95);
      }

      // Occasionally reset to base rate (simulates "fresh start" moments)
      if (_random.nextDouble() < 0.02) {
        showUpProbability = baseShowUpRate;
      }
    }
  }

  double _generateValue(Activity activity) {
    if (activity.isCompletion) {
      return 1.0;
    }

    // For quantity, generate varied but realistic values
    // Creates natural variation where some days are better than others
    final baseValue = 5 + _random.nextInt(6); // 5-10
    final variance = _random.nextDouble() * 4 - 2; // -2 to +2
    return (baseValue + variance).clamp(1.0, 15.0);
  }

  /// Clears all entries (useful for regenerating)
  Future<void> clearAllEntries() async {
    await _entryRepository.deleteAll();
  }
}
```

---

### 2. Create Riverpod Provider

Add to your providers file or create `lib/core/utils/mock_data_generator_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ember/core/utils/mock_data_generator.dart';
// Import your repository providers
import 'package:ember/features/activities/data/repositories/activity_repository_provider.dart';
import 'package:ember/features/activities/data/repositories/entry_repository_provider.dart';

final mockDataGeneratorProvider = Provider<MockDataGenerator>((ref) {
  return MockDataGenerator(
    activityRepository: ref.read(activityRepositoryProvider),
    entryRepository: ref.read(entryRepositoryProvider),
  );
});
```

---

### 3. Add Debug Button (Settings Screen or Home Screen)

Wrap in `kDebugMode` so it never shows in release builds:

```dart
import 'package:flutter/foundation.dart';

// Inside your widget build method, add this where appropriate:

if (kDebugMode) ...[
  const SizedBox(height: 16),
  const Divider(),
  const SizedBox(height: 16),
  Text(
    'Debug Tools',
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: 12,
    ),
  ),
  const SizedBox(height: 8),
  Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => _generateMockData(context, ref),
          child: const Text('Generate Mock Data'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton(
          onPressed: () => _clearAllData(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text('Clear All Data'),
        ),
      ),
    ],
  ),
],
```

---

### 4. Handler Functions

```dart
Future<void> _generateMockData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Generate Mock Data?'),
      content: const Text(
        'This will create entries for all activities from January 2025 to today. '
        'Existing entries will be kept.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Generate'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    // Show loading indicator
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating mock data...')),
      );
    }

    await ref.read(mockDataGeneratorProvider).generate();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock data generated! ✓')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear All Entries?'),
      content: const Text(
        'This will delete ALL entries for all activities. '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete Everything'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await ref.read(mockDataGeneratorProvider).clearAllEntries();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All entries cleared.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

---

### 5. Add deleteAll to Entry Repository (if not exists)

Make sure your entry repository has a `deleteAll` method:

```dart
// In entry_repository.dart (interface)
abstract class EntryRepository {
  // ... existing methods
  Future<void> deleteAll();
}

// In entry_repository_impl.dart (implementation)
@override
Future<void> deleteAll() async {
  await _entryBox.clear();
}
```

---

## Usage

1. Create 4-6 activities with different colors first
2. Go to Settings (or wherever you put the debug button)
3. Tap "Generate Mock Data"
4. Wait a few seconds
5. Heat maps should now be full and beautiful
6. Take screenshots
7. Use "Clear All Data" if you want to regenerate

---

## Before Release Checklist

- [ ] Remove debug buttons OR verify `kDebugMode` wrapping works
- [ ] Delete `mock_data_generator.dart` (optional, won't hurt if kDebugMode protected)
- [ ] Clear mock data from your device
- [ ] Test fresh install has no data

---

## Notes

- Generation takes a few seconds (writing ~365 entries per activity)
- The algorithm creates realistic patterns:
  - Natural streaks (probability increases when you show up)
  - Natural gaps (probability decreases when you miss)
  - Occasional "fresh starts" (random resets)
  - Different base rates per activity (some look more consistent than others)
- Quantity values vary between 1-15 with natural variation
