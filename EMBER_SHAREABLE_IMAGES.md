# Ember - Shareable Heat Map Images

## Overview

Users can share beautiful images of their heat maps to social media, messages, etc. This is a key growth feature—every shared image is free marketing.

---

## Packages Required

```yaml
dependencies:
  share_plus: ^10.0.0
  path_provider: ^2.1.0
```

Run `flutter pub get` after adding.

---

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  1. User taps "Share" button                                │
│                         ↓                                   │
│  2. Build ShareCard widget (not visible on screen)          │
│                         ↓                                   │
│  3. Wrap in RepaintBoundary with GlobalKey                  │
│                         ↓                                   │
│  4. Call toImage() on RenderRepaintBoundary                 │
│                         ↓                                   │
│  5. Convert to PNG bytes                                    │
│                         ↓                                   │
│  6. Write to temp file                                      │
│                         ↓                                   │
│  7. Open native share sheet via share_plus                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
lib/features/share/
├── domain/
│   └── usecases/
│       └── share_heat_map.dart
└── presentation/
    ├── widgets/
    │   ├── share_card.dart
    │   ├── share_card_heat_map.dart
    │   ├── share_card_stats.dart
    │   └── share_card_branding.dart
    └── utils/
        └── heat_map_image_generator.dart
```

---

## Implementation

### 1. Share Card Widget

This is a standalone widget designed specifically for export—not shown on screen.

`lib/features/share/presentation/widgets/share_card.dart`

```dart
import 'package:flutter/material.dart';

import 'package:ember/core/constants/app_colors.dart';
import 'package:ember/core/constants/app_dimensions.dart';
import 'package:ember/features/activities/domain/entities/activity.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';
import 'package:ember/features/share/presentation/widgets/share_card_heat_map.dart';
import 'package:ember/features/share/presentation/widgets/share_card_stats.dart';
import 'package:ember/features/share/presentation/widgets/share_card_branding.dart';

class ShareCard extends StatelessWidget {
  final Activity activity;
  final List<ActivityEntry> entries;
  final int year;

  /// Fixed dimensions for social sharing
  static const double width = 1080;
  static const double height = 1920; // Story format (9:16)
  // Alternative: 1080 x 1080 for square format

  const ShareCard({
    super.key,
    required this.activity,
    required this.entries,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = HabitGradientPresets.getById(activity.gradientId);
    
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          
          // Activity header
          _buildHeader(gradient),
          
          const SizedBox(height: 48),
          
          // Heat map
          Expanded(
            child: ShareCardHeatMap(
              entries: entries,
              year: year,
              gradient: gradient,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Stats
          ShareCardStats(
            entries: entries,
            year: year,
            gradient: gradient,
          ),
          
          const Spacer(),
          
          // Branding
          const ShareCardBranding(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(HabitGradient gradient) {
    return Row(
      children: [
        if (activity.emoji != null) ...[
          Text(
            activity.emoji!,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(width: 24),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                year.toString(),
                style: TextStyle(
                  color: gradient.max,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

### 2. Share Card Heat Map

`lib/features/share/presentation/widgets/share_card_heat_map.dart`

```dart
import 'package:flutter/material.dart';

import 'package:ember/core/constants/app_colors.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';

class ShareCardHeatMap extends StatelessWidget {
  final List<ActivityEntry> entries;
  final int year;
  final HabitGradient gradient;

  const ShareCardHeatMap({
    super.key,
    required this.entries,
    required this.year,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Build a map of date -> entry for quick lookup
    final entryMap = <DateTime, ActivityEntry>{};
    for (final entry in entries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entryMap[dateKey] = entry;
    }

    // Generate all weeks of the year
    final firstDay = DateTime(year, 1, 1);
    final lastDay = DateTime(year, 12, 31);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - (52 * 4)) / 53; // 53 weeks, 4px spacing
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildWeeks(
              firstDay: firstDay,
              lastDay: lastDay,
              entryMap: entryMap,
              cellSize: cellSize,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildWeeks({
    required DateTime firstDay,
    required DateTime lastDay,
    required Map<DateTime, ActivityEntry> entryMap,
    required double cellSize,
  }) {
    final weeks = <Widget>[];
    var currentDay = firstDay;

    while (currentDay.isBefore(lastDay) || currentDay.isAtSameMomentAs(lastDay)) {
      final weekDays = <Widget>[];
      
      // Fill empty cells for first week if year doesn't start on Sunday
      if (weeks.isEmpty) {
        for (var i = 0; i < currentDay.weekday % 7; i++) {
          weekDays.add(SizedBox(width: cellSize, height: cellSize));
        }
      }

      // Build days for this week
      while (weekDays.length < 7 && 
             (currentDay.isBefore(lastDay) || currentDay.isAtSameMomentAs(lastDay))) {
        final dateKey = DateTime(currentDay.year, currentDay.month, currentDay.day);
        final entry = entryMap[dateKey];
        final intensity = _calculateIntensity(entry);

        weekDays.add(
          Container(
            width: cellSize,
            height: cellSize,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: gradient.getColorForIntensity(intensity),
              borderRadius: BorderRadius.circular(4),
              boxShadow: intensity >= 0.9
                  ? [
                      BoxShadow(
                        color: gradient.glow.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );

        currentDay = currentDay.add(const Duration(days: 1));
      }

      weeks.add(
        Column(
          children: weekDays,
        ),
      );
    }

    return weeks;
  }

  double _calculateIntensity(ActivityEntry? entry) {
    if (entry == null || entry.value <= 0) return 0.0;
    
    // Simple intensity based on existence for share card
    // You can use your full percentile calculation here if preferred
    return entry.value > 0 ? 0.7 + (entry.value / 20).clamp(0.0, 0.3) : 0.0;
  }
}
```

---

### 3. Share Card Stats

`lib/features/share/presentation/widgets/share_card_stats.dart`

```dart
import 'package:flutter/material.dart';

import 'package:ember/core/constants/app_colors.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';

class ShareCardStats extends StatelessWidget {
  final List<ActivityEntry> entries;
  final int year;
  final HabitGradient gradient;

  const ShareCardStats({
    super.key,
    required this.entries,
    required this.year,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final daysLogged = _calculateDaysLogged();
    final longestStreak = _calculateLongestStreak();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStat('Showed up', '$daysLogged days', gradient),
        const SizedBox(height: 16),
        _buildStat('Longest streak', '$longestStreak days', gradient),
      ],
    );
  }

  Widget _buildStat(String label, String value, HabitGradient gradient) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 28,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: TextStyle(
            color: gradient.max,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  int _calculateDaysLogged() {
    final uniqueDays = entries
        .where((e) => e.value > 0)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    return uniqueDays.length;
  }

  int _calculateLongestStreak() {
    if (entries.isEmpty) return 0;

    final sortedDates = entries
        .where((e) => e.value > 0)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort();

    if (sortedDates.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      
      if (diff == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }
}
```

---

### 4. Share Card Branding

`lib/features/share/presentation/widgets/share_card_branding.dart`

```dart
import 'package:flutter/material.dart';

import 'package:ember/core/constants/app_colors.dart';

class ShareCardBranding extends StatelessWidget {
  const ShareCardBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App icon placeholder - replace with actual icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              '🔥',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Made with Ember',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
```

---

### 5. Heat Map Image Generator

`lib/features/share/presentation/utils/heat_map_image_generator.dart`

```dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ember/features/activities/domain/entities/activity.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';
import 'package:ember/features/share/presentation/widgets/share_card.dart';

class HeatMapImageGenerator {
  /// Generates a shareable image and returns the file path.
  static Future<String> generate({
    required Activity activity,
    required List<ActivityEntry> entries,
    required int year,
  }) async {
    // Create the share card widget
    final shareCard = ShareCard(
      activity: activity,
      entries: entries,
      year: year,
    );

    // Render to image
    final imageBytes = await _renderWidgetToImage(
      widget: shareCard,
      width: ShareCard.width,
      height: ShareCard.height,
    );

    // Save to temp file
    final filePath = await _saveToTempFile(
      bytes: imageBytes,
      fileName: 'ember_${activity.name.toLowerCase().replaceAll(' ', '_')}_$year.png',
    );

    return filePath;
  }

  static Future<List<int>> _renderWidgetToImage({
    required Widget widget,
    required double width,
    required double height,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.implicitView!,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        size: Size(width, height),
        devicePixelRatio: 3.0,
      ),
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: widget,
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static Future<String> _saveToTempFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
```

---

### 6. Share UseCase

`lib/features/share/domain/usecases/share_heat_map.dart`

```dart
import 'package:share_plus/share_plus.dart';

import 'package:ember/features/activities/domain/entities/activity.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';
import 'package:ember/features/activities/domain/repositories/entry_repository.dart';
import 'package:ember/features/share/presentation/utils/heat_map_image_generator.dart';

class ShareHeatMap {
  final EntryRepository _entryRepository;

  ShareHeatMap(this._entryRepository);

  Future<void> call({
    required Activity activity,
    int? year,
  }) async {
    final targetYear = year ?? DateTime.now().year;
    
    // Get entries for the year
    final entries = await _entryRepository.getEntriesInRange(
      activityId: activity.id,
      start: DateTime(targetYear, 1, 1),
      end: DateTime(targetYear, 12, 31),
    );

    // Generate image
    final filePath = await HeatMapImageGenerator.generate(
      activity: activity,
      entries: entries,
      year: targetYear,
    );

    // Share
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'My ${activity.name} journey in $targetYear 🔥\n\nTracked with Ember',
    );
  }
}
```

---

### 7. Riverpod Provider

`lib/features/share/domain/usecases/share_heat_map_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ember/features/activities/data/repositories/entry_repository_provider.dart';
import 'package:ember/features/share/domain/usecases/share_heat_map.dart';

final shareHeatMapProvider = Provider<ShareHeatMap>((ref) {
  return ShareHeatMap(ref.read(entryRepositoryProvider));
});
```

---

### 8. Add Share Button to Activity Detail Screen

```dart
// In your activity detail screen or heat map screen

IconButton(
  icon: const Icon(Icons.share),
  onPressed: () => _shareHeatMap(context, ref, activity),
),

// Handler
Future<void> _shareHeatMap(
  BuildContext context,
  WidgetRef ref,
  Activity activity,
) async {
  try {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating image...'),
        duration: Duration(seconds: 1),
      ),
    );

    await ref.read(shareHeatMapProvider).call(activity: activity);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }
}
```

---

## Share Card Sizes

| Format | Dimensions | Use Case |
|--------|------------|----------|
| Story | 1080 × 1920 | Instagram/Facebook stories |
| Square | 1080 × 1080 | Instagram feed, Twitter |
| Wide | 1200 × 630 | LinkedIn, Facebook feed |

Currently implemented: **Story format (1080 × 1920)**

To support multiple formats, add a parameter to `ShareCard` and `HeatMapImageGenerator`.

---

## Optional Enhancements

### 1. Format Picker

Let users choose format before sharing:

```dart
enum ShareFormat {
  story(1080, 1920, 'Story'),
  square(1080, 1080, 'Square'),
  wide(1200, 630, 'Wide');

  final double width;
  final double height;
  final String label;

  const ShareFormat(this.width, this.height, this.label);
}
```

### 2. Loading Overlay

Show a proper loading state while generating:

```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => const Center(
    child: CircularProgressIndicator(),
  ),
);

// Generate and share...

Navigator.pop(context); // Dismiss loading
```

### 3. Preview Before Sharing

Show the generated image in a dialog before sharing:

```dart
// After generating, show preview
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    content: Image.file(File(filePath)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          Share.shareXFiles([XFile(filePath)]);
        },
        child: const Text('Share'),
      ),
    ],
  ),
);
```

---

## Summary

| Component | Purpose |
|-----------|---------|
| `ShareCard` | Widget designed for export (fixed size, branding) |
| `ShareCardHeatMap` | Heat map grid for the share card |
| `ShareCardStats` | Days logged + longest streak |
| `ShareCardBranding` | "Made with Ember" footer |
| `HeatMapImageGenerator` | Renders widget to PNG file |
| `ShareHeatMap` | UseCase tying it all together |

Users tap share → beautiful image generated → native share sheet opens → free marketing for Ember. 🔥
