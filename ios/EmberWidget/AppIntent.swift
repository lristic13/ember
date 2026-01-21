//
//  AppIntent.swift
//  EmberWidget
//
//  Created by Lazar on 20. 1. 2026..
//

import WidgetKit
import AppIntents

// MARK: - Activity Entity

struct ActivityEntity: AppEntity {
    let id: String
    let name: String
    let emoji: String?

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Activity"
    }

    var displayRepresentation: DisplayRepresentation {
        let title = emoji != nil ? "\(emoji!) \(name)" : name
        return DisplayRepresentation(title: "\(title)")
    }

    static var defaultQuery = ActivityEntityQuery()
}

// MARK: - Activity Entity Query

struct ActivityEntityQuery: EntityQuery {
    func entities(for identifiers: [ActivityEntity.ID]) async throws -> [ActivityEntity] {
        let allActivities = loadAvailableActivities()
        return allActivities.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ActivityEntity] {
        return loadAvailableActivities()
    }

    func defaultResult() async -> ActivityEntity? {
        return loadAvailableActivities().first
    }

    private func loadAvailableActivities() -> [ActivityEntity] {
        guard let userDefaults = UserDefaults(suiteName: "group.com.lristic.ember"),
              let jsonString = userDefaults.string(forKey: "available_activities"),
              let data = jsonString.data(using: .utf8),
              let activities = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            return []
        }

        return activities.compactMap { dict -> ActivityEntity? in
            guard let id = dict["id"] as? String,
                  let name = dict["name"] as? String else {
                return nil
            }
            let emoji = dict["emoji"] as? String
            return ActivityEntity(id: id, name: name, emoji: emoji)
        }
    }
}

// MARK: - Configuration Intent

struct SelectActivityIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Select Activity" }
    static var description: IntentDescription { "Choose which activity to display in the widget." }

    @Parameter(title: "Activity")
    var activity: ActivityEntity?
}

// MARK: - Quick Log Intent

struct QuickLogIntent: AppIntent {
    static var title: LocalizedStringResource { "Quick Log" }
    static var description: IntentDescription { "Log activity from widget" }

    @Parameter(title: "Activity ID")
    var activityId: String

    @Parameter(title: "Is Completion")
    var isCompletion: Bool

    init() {
        self.activityId = ""
        self.isCompletion = false
    }

    init(activityId: String, isCompletion: Bool) {
        self.activityId = activityId
        self.isCompletion = isCompletion
    }

    func perform() async throws -> some IntentResult {
        guard let userDefaults = UserDefaults(suiteName: "group.com.lristic.ember"),
              let jsonString = userDefaults.string(forKey: "activity_\(activityId)"),
              let data = jsonString.data(using: .utf8),
              var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return .result()
        }

        // Get current today value
        let currentValue = json["todayValue"] as? Double ?? 0

        // Calculate new value
        let newValue: Double
        if isCompletion {
            // Toggle: 0 -> 1, anything else -> 0
            newValue = currentValue > 0 ? 0 : 1
        } else {
            // Increment by 1
            newValue = currentValue + 1
        }

        // Update today's value
        json["todayValue"] = newValue

        // Update week values (today is the last entry based on weekday)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Convert to Monday-based index (Mon=0, Sun=6)
        let dayIndex = (weekday + 5) % 7

        // Handle weekValues as either [Double] or [Int] (JSON might serialize as integers)
        if let weekValuesRaw = json["weekValues"] as? [Any], dayIndex < weekValuesRaw.count {
            var weekValues = weekValuesRaw.map { value -> Double in
                if let doubleVal = value as? Double { return doubleVal }
                if let intVal = value as? Int { return Double(intVal) }
                return 0.0
            }
            weekValues[dayIndex] = newValue
            json["weekValues"] = weekValues
        }

        // Update streak if completing (not decrementing)
        if newValue > currentValue {
            let currentStreak = json["currentStreak"] as? Int ?? 0
            // Only increment streak if this is the first log today
            if currentValue == 0 {
                json["currentStreak"] = currentStreak + 1
            }
        } else if newValue == 0 && currentValue > 0 {
            // Decrement streak if un-completing
            let currentStreak = json["currentStreak"] as? Int ?? 0
            json["currentStreak"] = max(0, currentStreak - 1)
        }

        // Save updated data
        if let updatedData = try? JSONSerialization.data(withJSONObject: json),
           let updatedString = String(data: updatedData, encoding: .utf8) {
            userDefaults.set(updatedString, forKey: "activity_\(activityId)")

            // Also save to a pending sync key so Flutter knows to sync this change
            var pendingLogs: [[String: Any]] = []
            if let existingLogsString = userDefaults.string(forKey: "pending_widget_logs"),
               let existingData = existingLogsString.data(using: .utf8),
               let existingLogs = try? JSONSerialization.jsonObject(with: existingData) as? [[String: Any]] {
                pendingLogs = existingLogs
            }
            pendingLogs.append([
                "habitId": activityId,
                "value": newValue,
                "timestamp": Date().timeIntervalSince1970
            ])
            if let logsData = try? JSONSerialization.data(withJSONObject: pendingLogs),
               let logsString = String(data: logsData, encoding: .utf8) {
                userDefaults.set(logsString, forKey: "pending_widget_logs")
            }
        }

        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "EmberWidget")

        return .result()
    }
}
