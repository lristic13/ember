# Ember - Home Screen Widgets

## Overview

Home screen widgets let users quickly view and log activities without opening the app. Each widget displays a single activity with today's status, current streak, a mini heat map of the current week, and a quick-log button.

---

## Widget Spec

| Attribute | Value |
|-----------|-------|
| Type | One widget per activity |
| Size | Medium |
| Selection | User picks activity when adding widget |

### Display Elements

- Activity emoji + name
- Today's value/status
- Current streak (🔥 X days)
- Mini heat map (current week, Mon-Sun)
- Action button

### Actions

| Tap Target | Behavior |
|------------|----------|
| "+" or "✓" button | Logs directly (+1 for quantity, marks done for completion) |
| Anywhere else | Opens app to that activity |

### Visual Layout

**Quantity type:**
```
┌─────────────────────────────────┐
│  💧 Water                       │
│  8 glasses today   🔥 5 days    │
│                                 │
│  [ ▪ ▪ ▪ ░ ▪ ▪ ░ ]             │
│    M T W T F S S               │
│                                 │
│            [ + ]                │
└─────────────────────────────────┘
```

**Completion type:**
```
┌─────────────────────────────────┐
│  🏋️ Workout                     │
│  Done today        🔥 2 days    │
│                                 │
│  [ ░ ▪ ▪ ░ ▪ ▪ ░ ]             │
│    M T W T F S S               │
│                                 │
│            [ ✓ ]                │
└─────────────────────────────────┘
```

---

## Package

```yaml
dependencies:
  home_widget: ^0.6.0
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter App                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  HomeWidgetService                                   │    │
│  │  - Saves activity data to shared storage            │    │
│  │  - Triggers widget refresh                          │    │
│  │  - Handles callbacks from widget taps               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ SharedPreferences (Android)
                              │ UserDefaults (iOS)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Native Widgets                          │
│  ┌────────────────────┐    ┌────────────────────┐          │
│  │   iOS (WidgetKit)  │    │ Android (Glance)   │          │
│  │   Swift + SwiftUI  │    │ Kotlin + Compose   │          │
│  └────────────────────┘    └────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## Flutter Side Implementation

### 1. Data Model for Widget

Create `lib/features/widgets/domain/entities/widget_activity_data.dart`:

```dart
class WidgetActivityData {
  final String id;
  final String name;
  final String? emoji;
  final bool isCompletion;
  final String? unit;
  final double todayValue;
  final int currentStreak;
  final List<double> weekValues; // Mon-Sun, 7 values
  final String gradientId;

  const WidgetActivityData({
    required this.id,
    required this.name,
    this.emoji,
    required this.isCompletion,
    this.unit,
    required this.todayValue,
    required this.currentStreak,
    required this.weekValues,
    required this.gradientId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'isCompletion': isCompletion,
    'unit': unit,
    'todayValue': todayValue,
    'currentStreak': currentStreak,
    'weekValues': weekValues,
    'gradientId': gradientId,
  };

  factory WidgetActivityData.fromJson(Map<String, dynamic> json) {
    return WidgetActivityData(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      isCompletion: json['isCompletion'] as bool,
      unit: json['unit'] as String?,
      todayValue: (json['todayValue'] as num).toDouble(),
      currentStreak: json['currentStreak'] as int,
      weekValues: (json['weekValues'] as List).map((e) => (e as num).toDouble()).toList(),
      gradientId: json['gradientId'] as String,
    );
  }
}
```

### 2. Widget Service

Create `lib/features/widgets/data/services/home_widget_service.dart`:

```dart
import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import 'package:ember/features/activities/domain/entities/activity.dart';
import 'package:ember/features/activities/domain/entities/activity_entry.dart';
import 'package:ember/features/activities/domain/repositories/activity_repository.dart';
import 'package:ember/features/activities/domain/repositories/entry_repository.dart';
import 'package:ember/features/widgets/domain/entities/widget_activity_data.dart';

class HomeWidgetService {
  final ActivityRepository _activityRepository;
  final EntryRepository _entryRepository;

  static const String _appGroupId = 'group.com.yourcompany.ember'; // iOS App Group
  static const String _iOSWidgetName = 'EmberWidget';
  static const String _androidWidgetName = 'EmberWidgetReceiver';

  HomeWidgetService({
    required ActivityRepository activityRepository,
    required EntryRepository entryRepository,
  })  : _activityRepository = activityRepository,
        _entryRepository = entryRepository;

  /// Initialize home widget functionality
  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    
    // Register callback for when widget is tapped
    HomeWidget.widgetClicked.listen(_handleWidgetClick);
  }

  /// Update widget data for a specific activity
  Future<void> updateActivityWidget(String activityId) async {
    final activity = await _activityRepository.getById(activityId);
    if (activity == null) return;

    final widgetData = await _buildWidgetData(activity);
    
    // Save data with activity ID as key
    await HomeWidget.saveWidgetData(
      'activity_$activityId',
      jsonEncode(widgetData.toJson()),
    );

    // Trigger widget refresh
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  /// Update all activity widgets
  Future<void> updateAllWidgets() async {
    final activities = await _activityRepository.getAll();
    
    for (final activity in activities) {
      if (!activity.isArchived) {
        final widgetData = await _buildWidgetData(activity);
        await HomeWidget.saveWidgetData(
          'activity_${activity.id}',
          jsonEncode(widgetData.toJson()),
        );
      }
    }

    // Save list of available activities for widget configuration
    final activityList = activities
        .where((a) => !a.isArchived)
        .map((a) => {
          'id': a.id,
          'name': a.name,
          'emoji': a.emoji,
        })
        .toList();
    
    await HomeWidget.saveWidgetData(
      'available_activities',
      jsonEncode(activityList),
    );

    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  /// Build widget data for an activity
  Future<WidgetActivityData> _buildWidgetData(Activity activity) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get current week's dates (Monday to Sunday)
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = today.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    // Get entries for the week
    final weekEntries = await _entryRepository.getEntriesInRange(
      activityId: activity.id,
      start: monday,
      end: sunday,
    );

    // Build week values array (Mon-Sun)
    final weekValues = List<double>.filled(7, 0.0);
    for (final entry in weekEntries) {
      final dayIndex = entry.date.weekday - 1; // 0 = Monday
      if (dayIndex >= 0 && dayIndex < 7) {
        weekValues[dayIndex] = entry.value;
      }
    }

    // Get today's value
    final todayEntry = weekEntries.firstWhere(
      (e) => e.date.year == today.year && 
             e.date.month == today.month && 
             e.date.day == today.day,
      orElse: () => ActivityEntry(
        id: '',
        activityId: activity.id,
        date: today,
        value: 0,
      ),
    );

    // Calculate current streak
    final currentStreak = await _calculateCurrentStreak(activity.id);

    return WidgetActivityData(
      id: activity.id,
      name: activity.name,
      emoji: activity.emoji,
      isCompletion: activity.isCompletion,
      unit: activity.unit,
      todayValue: todayEntry.value,
      currentStreak: currentStreak,
      weekValues: weekValues,
      gradientId: activity.gradientId,
    );
  }

  /// Calculate current streak for an activity
  Future<int> _calculateCurrentStreak(String activityId) async {
    final now = DateTime.now();
    var currentDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // Check if today is logged, if not start from yesterday
    final todayEntry = await _entryRepository.getEntryForDate(
      activityId: activityId,
      date: currentDate,
    );
    
    if (todayEntry == null || todayEntry.value <= 0) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    // Count consecutive days backwards
    while (true) {
      final entry = await _entryRepository.getEntryForDate(
        activityId: activityId,
        date: currentDate,
      );

      if (entry != null && entry.value > 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Handle widget tap callback
  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    final action = uri.host;
    final activityId = uri.queryParameters['activityId'];

    if (activityId == null) return;

    switch (action) {
      case 'log':
        _handleQuickLog(activityId);
        break;
      case 'open':
        _handleOpenActivity(activityId);
        break;
    }
  }

  /// Handle quick log from widget (+1 or mark done)
  Future<void> _handleQuickLog(String activityId) async {
    final activity = await _activityRepository.getById(activityId);
    if (activity == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get existing entry for today
    final existingEntry = await _entryRepository.getEntryForDate(
      activityId: activityId,
      date: today,
    );

    final double newValue;
    if (activity.isCompletion) {
      // Toggle completion
      newValue = (existingEntry?.value ?? 0) > 0 ? 0.0 : 1.0;
    } else {
      // Add +1 to quantity
      newValue = (existingEntry?.value ?? 0) + 1;
    }

    if (existingEntry != null) {
      await _entryRepository.update(existingEntry.copyWith(value: newValue));
    } else {
      await _entryRepository.save(ActivityEntry(
        id: const Uuid().v4(),
        activityId: activityId,
        date: today,
        value: newValue,
      ));
    }

    // Update widget to reflect change
    await updateActivityWidget(activityId);
  }

  /// Handle opening activity in app
  void _handleOpenActivity(String activityId) {
    // This will be handled by the app's navigation
    // The URI will be: ember://open?activityId=xxx
    // Your app should listen for this and navigate accordingly
  }
}
```

### 3. Riverpod Provider

Create `lib/features/widgets/data/services/home_widget_service_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ember/features/activities/data/repositories/activity_repository_provider.dart';
import 'package:ember/features/activities/data/repositories/entry_repository_provider.dart';
import 'package:ember/features/widgets/data/services/home_widget_service.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService(
    activityRepository: ref.read(activityRepositoryProvider),
    entryRepository: ref.read(entryRepositoryProvider),
  );
});
```

### 4. Initialize in Main

Update `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... other initialization ...

  // Initialize home widgets
  final container = ProviderContainer();
  await container.read(homeWidgetServiceProvider).initialize();

  // Listen for widget clicks when app is launched
  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) {
      // Handle navigation based on URI
      // ember://open?activityId=xxx -> navigate to activity
      // ember://log?activityId=xxx -> handled by service
    }
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EmberApp(),
    ),
  );
}
```

### 5. Update Widgets When Data Changes

Call this whenever an entry is logged or activity is modified:

```dart
// In your entry logging logic:
await entryRepository.save(entry);
await ref.read(homeWidgetServiceProvider).updateActivityWidget(entry.activityId);

// When activity is created/updated:
await activityRepository.save(activity);
await ref.read(homeWidgetServiceProvider).updateAllWidgets();
```

---

## iOS Implementation (WidgetKit + SwiftUI)

### 1. Add Widget Extension in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
3. Name it `EmberWidget`
4. Uncheck "Include Configuration Intent" (we'll add it manually)
5. Finish

### 2. Configure App Group

1. Select Runner target → Signing & Capabilities → + Capability → App Groups
2. Add `group.com.yourcompany.ember`
3. Select EmberWidget target → do the same

### 3. Widget Files

Create these files in `ios/EmberWidget/`:

**EmberWidget.swift:**

```swift
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.ember")
    
    func placeholder(in context: Context) -> EmberEntry {
        EmberEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (EmberEntry) -> Void) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EmberEntry>) -> Void) {
        let entry = getEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getEntry() -> EmberEntry {
        // Get selected activity ID from widget configuration
        guard let activityId = userDefaults?.string(forKey: "selected_activity_id"),
              let dataString = userDefaults?.string(forKey: "activity_\(activityId)"),
              let data = dataString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return EmberEntry.placeholder
        }
        
        return EmberEntry(
            date: Date(),
            activityId: json["id"] as? String ?? "",
            name: json["name"] as? String ?? "Activity",
            emoji: json["emoji"] as? String,
            isCompletion: json["isCompletion"] as? Bool ?? false,
            unit: json["unit"] as? String,
            todayValue: json["todayValue"] as? Double ?? 0,
            currentStreak: json["currentStreak"] as? Int ?? 0,
            weekValues: json["weekValues"] as? [Double] ?? Array(repeating: 0, count: 7),
            gradientId: json["gradientId"] as? String ?? "ember"
        )
    }
}

struct EmberEntry: TimelineEntry {
    let date: Date
    let activityId: String
    let name: String
    let emoji: String?
    let isCompletion: Bool
    let unit: String?
    let todayValue: Double
    let currentStreak: Int
    let weekValues: [Double]
    let gradientId: String
    
    static var placeholder: EmberEntry {
        EmberEntry(
            date: Date(),
            activityId: "",
            name: "Water",
            emoji: "💧",
            isCompletion: false,
            unit: "glasses",
            todayValue: 8,
            currentStreak: 5,
            weekValues: [1, 1, 1, 0, 1, 1, 0],
            gradientId: "ocean"
        )
    }
}

struct EmberWidgetEntryView: View {
    var entry: EmberEntry
    
    private var gradientColor: Color {
        // Map gradient IDs to colors
        switch entry.gradientId {
        case "ember": return Color(red: 1.0, green: 0.42, blue: 0.1)
        case "coral": return Color(red: 1.0, green: 0.42, blue: 0.42)
        case "sunflower": return Color(red: 1.0, green: 0.85, blue: 0.24)
        case "mint": return Color(red: 0.42, green: 0.8, blue: 0.47)
        case "ocean": return Color(red: 0.3, green: 0.59, blue: 1.0)
        case "lavender": return Color(red: 0.69, green: 0.52, blue: 0.96)
        case "rose": return Color(red: 1.0, green: 0.56, blue: 0.67)
        case "teal": return Color(red: 0.3, green: 0.82, blue: 0.88)
        case "sand": return Color(red: 0.83, green: 0.65, blue: 0.45)
        case "silver": return Color(red: 0.69, green: 0.69, blue: 0.69)
        case "ruby": return Color(red: 0.9, green: 0.22, blue: 0.21)
        case "peach": return Color(red: 1.0, green: 0.67, blue: 0.57)
        case "lime": return Color(red: 0.68, green: 0.92, blue: 0.0)
        case "sky": return Color(red: 0.51, green: 0.83, blue: 0.98)
        case "violet": return Color(red: 0.49, green: 0.3, blue: 1.0)
        case "magenta": return Color(red: 1.0, green: 0.25, blue: 0.51)
        case "amber": return Color(red: 1.0, green: 0.7, blue: 0.0)
        case "sage": return Color(red: 0.65, green: 0.84, blue: 0.65)
        case "slate": return Color(red: 0.56, green: 0.64, blue: 0.68)
        case "copper": return Color(red: 0.72, green: 0.45, blue: 0.2)
        default: return Color(red: 1.0, green: 0.42, blue: 0.1)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: emoji + name
            HStack {
                if let emoji = entry.emoji {
                    Text(emoji)
                        .font(.title2)
                }
                Text(entry.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Status + streak
            HStack {
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                if entry.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Text("🔥")
                            .font(.caption)
                        Text("\(entry.currentStreak) days")
                            .font(.caption)
                            .foregroundColor(gradientColor)
                    }
                }
            }
            
            Spacer()
            
            // Mini heat map (current week)
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(cellColor(for: entry.weekValues[index]))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            
            // Day labels
            HStack(spacing: 4) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
            
            // Action button
            Link(destination: URL(string: "ember://log?activityId=\(entry.activityId)")!) {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(gradientColor)
                            .frame(width: 44, height: 44)
                        Text(entry.isCompletion ? "✓" : "+")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
        .widgetURL(URL(string: "ember://open?activityId=\(entry.activityId)"))
    }
    
    private var statusText: String {
        if entry.isCompletion {
            return entry.todayValue > 0 ? "Done today" : "Not yet today"
        } else {
            let value = Int(entry.todayValue)
            let unit = entry.unit ?? ""
            return "\(value) \(unit) today"
        }
    }
    
    private func cellColor(for value: Double) -> Color {
        if value <= 0 {
            return Color(red: 0.1, green: 0.1, blue: 0.12)
        }
        return gradientColor.opacity(0.4 + (value > 0 ? 0.6 : 0))
    }
}

@main
struct EmberWidget: Widget {
    let kind: String = "EmberWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EmberWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ember Activity")
        .description("Track your activity at a glance.")
        .supportedFamilies([.systemMedium])
    }
}

struct EmberWidget_Previews: PreviewProvider {
    static var previews: some View {
        EmberWidgetEntryView(entry: EmberEntry.placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
```

### 4. Handle URL Scheme in iOS

Update `ios/Runner/Info.plist` to add URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ember</string>
        </array>
    </dict>
</array>
```

---

## Android Implementation (Kotlin)

### 1. Create Widget Receiver

Create `android/app/src/main/kotlin/com/yourcompany/ember/EmberWidgetReceiver.kt`:

```kotlin
package com.yourcompany.ember

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class EmberWidgetReceiver : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.ember_widget)
            
            // Get selected activity ID for this widget
            val activityId = widgetData.getString("selected_activity_id_$widgetId", null)
            
            if (activityId != null) {
                val dataString = widgetData.getString("activity_$activityId", null)
                
                if (dataString != null) {
                    try {
                        val json = JSONObject(dataString)
                        
                        // Set activity info
                        val emoji = json.optString("emoji", "")
                        val name = json.getString("name")
                        val isCompletion = json.getBoolean("isCompletion")
                        val unit = json.optString("unit", "")
                        val todayValue = json.getDouble("todayValue")
                        val currentStreak = json.getInt("currentStreak")
                        
                        views.setTextViewText(R.id.activity_emoji, emoji)
                        views.setTextViewText(R.id.activity_name, name)
                        
                        // Status text
                        val statusText = if (isCompletion) {
                            if (todayValue > 0) "Done today" else "Not yet today"
                        } else {
                            "${todayValue.toInt()} $unit today"
                        }
                        views.setTextViewText(R.id.status_text, statusText)
                        
                        // Streak
                        if (currentStreak > 0) {
                            views.setTextViewText(R.id.streak_text, "🔥 $currentStreak days")
                        } else {
                            views.setTextViewText(R.id.streak_text, "")
                        }
                        
                        // Week heat map values
                        val weekValues = json.getJSONArray("weekValues")
                        val weekViewIds = listOf(
                            R.id.day_mon, R.id.day_tue, R.id.day_wed,
                            R.id.day_thu, R.id.day_fri, R.id.day_sat, R.id.day_sun
                        )
                        
                        weekViewIds.forEachIndexed { index, viewId ->
                            val value = weekValues.getDouble(index)
                            val alpha = if (value > 0) 255 else 50
                            views.setInt(viewId, "setBackgroundColor", 
                                getGradientColor(json.getString("gradientId"), alpha))
                        }
                        
                        // Action button text
                        views.setTextViewText(R.id.action_button, if (isCompletion) "✓" else "+")
                        
                        // Set click intents
                        val logIntent = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("ember://log?activityId=$activityId")
                        )
                        views.setOnClickPendingIntent(R.id.action_button, logIntent)
                        
                        val openIntent = HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java,
                            Uri.parse("ember://open?activityId=$activityId")
                        )
                        views.setOnClickPendingIntent(R.id.widget_container, openIntent)
                        
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
    
    private fun getGradientColor(gradientId: String, alpha: Int): Int {
        val color = when (gradientId) {
            "ember" -> 0xFF6B1A
            "coral" -> 0xFF6B6B
            "sunflower" -> 0xFFD93D
            "mint" -> 0x6BCB77
            "ocean" -> 0x4D96FF
            "lavender" -> 0xB085F5
            "rose" -> 0xFF8FAB
            "teal" -> 0x4DD0E1
            "sand" -> 0xD4A574
            "silver" -> 0xB0B0B0
            "ruby" -> 0xE53935
            "peach" -> 0xFFAB91
            "lime" -> 0xAEEA00
            "sky" -> 0x81D4FA
            "violet" -> 0x7C4DFF
            "magenta" -> 0xFF4081
            "amber" -> 0xFFB300
            "sage" -> 0xA5D6A7
            "slate" -> 0x90A4AE
            "copper" -> 0xB87333
            else -> 0xFF6B1A
        }
        return (alpha shl 24) or color
    }
}
```

### 2. Create Widget Layout

Create `android/app/src/main/res/layout/ember_widget.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_container"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="#0D0D0F">

    <!-- Header -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical">

        <TextView
            android:id="@+id/activity_emoji"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textSize="24sp"
            android:text="💧" />

        <TextView
            android:id="@+id/activity_name"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:layout_marginStart="8dp"
            android:textColor="#F5F5F5"
            android:textSize="16sp"
            android:textStyle="bold"
            android:text="Activity" />
    </LinearLayout>

    <!-- Status + Streak -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="4dp">

        <TextView
            android:id="@+id/status_text"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:textColor="#A0A0A0"
            android:textSize="12sp"
            android:text="0 today" />

        <TextView
            android:id="@+id/streak_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#FF6B1A"
            android:textSize="12sp"
            android:text="🔥 5 days" />
    </LinearLayout>

    <!-- Heat Map (Current Week) -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="16dp"
        android:gravity="center">

        <View android:id="@+id/day_mon"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />

        <View android:id="@+id/day_tue"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />

        <View android:id="@+id/day_wed"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />

        <View android:id="@+id/day_thu"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />

        <View android:id="@+id/day_fri"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />

        <View android:id="@+id/day_sat"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />

        <View android:id="@+id/day_sun"
            android:layout_width="0dp"
            android:layout_height="24dp"
            android:layout_weight="1"
            android:layout_margin="2dp"
            android:background="#1A1A1E" />
    </LinearLayout>

    <!-- Day Labels -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="2dp">

        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="M" android:textColor="#606060" android:textSize="10sp" />
        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="T" android:textColor="#606060" android:textSize="10sp" />
        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="W" android:textColor="#606060" android:textSize="10sp" />
        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="T" android:textColor="#606060" android:textSize="10sp" />
        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="F" android:textColor="#606060" android:textSize="10sp" />
        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="S" android:textColor="#606060" android:textSize="10sp" />
        <TextView android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:gravity="center"
            android:text="S" android:textColor="#606060" android:textSize="10sp" />
    </LinearLayout>

    <View
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1" />

    <!-- Action Button -->
    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal">

        <Button
            android:id="@+id/action_button"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_gravity="center"
            android:background="@drawable/circle_button"
            android:text="+"
            android:textColor="#FFFFFF"
            android:textSize="24sp"
            android:textStyle="bold" />
    </FrameLayout>

</LinearLayout>
```

### 3. Create Button Drawable

Create `android/app/src/main/res/drawable/circle_button.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#FF6B1A" />
</shape>
```

### 4. Widget Info

Create `android/app/src/main/res/xml/ember_widget_info.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:updatePeriodMillis="900000"
    android:initialLayout="@layout/ember_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:previewImage="@mipmap/ic_launcher" />
```

### 5. Register in AndroidManifest

Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<receiver android:name=".EmberWidgetReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/ember_widget_info" />
</receiver>
```

### 6. Add Intent Filter for URL Scheme

In `AndroidManifest.xml`, add to MainActivity:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="ember" />
</intent-filter>
```

---

## Testing

### iOS
1. Build and run on a real device
2. Long press home screen → Add Widget → Find Ember
3. Add medium widget
4. Widget should display activity data

### Android
1. Build and run on a real device
2. Long press home screen → Widgets → Find Ember
3. Drag widget to home screen
4. Widget should display activity data

**Note:** Simulators/emulators often have issues with widgets. Always test on real devices.

---

## Checklist

### Flutter Side
- [ ] `WidgetActivityData` model
- [ ] `HomeWidgetService` with data saving and callbacks
- [ ] Initialize service in `main.dart`
- [ ] Call `updateActivityWidget()` when entries change
- [ ] Call `updateAllWidgets()` when activities change

### iOS
- [ ] Add Widget Extension target
- [ ] Configure App Groups
- [ ] Implement `EmberWidget.swift`
- [ ] Add URL scheme to Info.plist

### Android
- [ ] Create `EmberWidgetReceiver.kt`
- [ ] Create `ember_widget.xml` layout
- [ ] Create `ember_widget_info.xml`
- [ ] Create `circle_button.xml` drawable
- [ ] Register receiver in `AndroidManifest.xml`
- [ ] Add intent filter for URL scheme

---

## Summary

| Platform | UI Technology | Data Sharing |
|----------|---------------|--------------|
| iOS | SwiftUI + WidgetKit | UserDefaults (App Group) |
| Android | XML Layout | SharedPreferences |
| Flutter | home_widget package | Bridges both platforms |

The `home_widget` package handles data sharing. Native code handles rendering and interactions. Quick logging (+1 or mark done) works directly from the widget without opening the app.
