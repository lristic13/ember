//
//  EmberWidget.swift
//  EmberWidget
//
//  Created by Lazar on 20. 1. 2026..
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

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
    let isPlaceholder: Bool
    let notFound: Bool

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
            gradientId: "ocean",
            isPlaceholder: true,
            notFound: false
        )
    }

    static var notConfigured: EmberEntry {
        EmberEntry(
            date: Date(),
            activityId: "",
            name: "Select Activity",
            emoji: nil,
            isCompletion: false,
            unit: nil,
            todayValue: 0,
            currentStreak: 0,
            weekValues: [0, 0, 0, 0, 0, 0, 0],
            gradientId: "ember",
            isPlaceholder: false,
            notFound: true
        )
    }
}

// MARK: - Timeline Provider

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> EmberEntry {
        EmberEntry.placeholder
    }

    func snapshot(for configuration: SelectActivityIntent, in context: Context) async -> EmberEntry {
        return getEntry(for: configuration)
    }

    func timeline(for configuration: SelectActivityIntent, in context: Context) async -> Timeline<EmberEntry> {
        let entry = getEntry(for: configuration)
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func getEntry(for configuration: SelectActivityIntent) -> EmberEntry {
        guard let activity = configuration.activity else {
            return EmberEntry.notConfigured
        }

        guard let userDefaults = UserDefaults(suiteName: "group.com.lristic.ember"),
              let jsonString = userDefaults.string(forKey: "activity_\(activity.id)"),
              let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return EmberEntry.notConfigured
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
            weekValues: (json["weekValues"] as? [Double]) ?? Array(repeating: 0, count: 7),
            gradientId: json["gradientId"] as? String ?? "ember",
            isPlaceholder: false,
            notFound: false
        )
    }
}

// MARK: - Widget View

struct EmberWidgetEntryView: View {
    var entry: EmberEntry

    private var gradientColor: Color {
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
        if entry.notFound {
            notConfiguredView
        } else {
            mainView
        }
    }

    private var notConfiguredView: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            Text("Tap to select activity")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mainView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header: emoji + name
            HStack(spacing: 6) {
                if let emoji = entry.emoji {
                    Text(emoji)
                        .font(.title3)
                }
                Text(entry.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
            }

            // Status + streak
            HStack {
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.6))
                    .lineLimit(1)
                Spacer()
                if entry.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Text("🔥")
                            .font(.caption)
                        Text("\(entry.currentStreak)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(gradientColor)
                    }
                }
            }

            Spacer(minLength: 4)

            // Mini heat map (current week)
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cellColor(for: entry.weekValues[index]))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }

            // Day labels
            HStack(spacing: 3) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8))
                        .foregroundColor(Color(white: 0.45))
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer(minLength: 4)

            // Action button
            HStack {
                Spacer()
                Link(destination: URL(string: "ember://log?habitId=\(entry.activityId)")!) {
                    ZStack {
                        Circle()
                            .fill(gradientColor)
                            .frame(width: 36, height: 36)
                        Text(entry.isCompletion ? "✓" : "+")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
        }
        .padding(12)
        .widgetURL(URL(string: "ember://open?habitId=\(entry.activityId)"))
    }

    private var statusText: String {
        if entry.isCompletion {
            return entry.todayValue > 0 ? "Done today" : "Not yet"
        } else {
            let value = Int(entry.todayValue)
            if let unit = entry.unit, !unit.isEmpty {
                return "\(value) \(unit)"
            }
            return "\(value) today"
        }
    }

    private func cellColor(for value: Double) -> Color {
        if value <= 0 {
            return Color(red: 0.1, green: 0.1, blue: 0.12)
        }
        return gradientColor.opacity(0.8)
    }
}

// MARK: - Widget Configuration

struct EmberWidget: Widget {
    let kind: String = "EmberWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectActivityIntent.self, provider: Provider()) { entry in
            EmberWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.05, green: 0.05, blue: 0.06), for: .widget)
        }
        .configurationDisplayName("Ember Activity")
        .description("Track your activity at a glance.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    EmberWidget()
} timeline: {
    EmberEntry.placeholder
    EmberEntry.notConfigured
}
