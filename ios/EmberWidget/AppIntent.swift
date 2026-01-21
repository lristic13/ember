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
