import Foundation
import SwiftData

enum ReminderNotificationMode: String, Codable, CaseIterable, Identifiable {
    case reminder, alarm
    var id: String { rawValue }
    var title: String { self == .alarm ? "Alarme" : "Lembrete" }
}

@Model
final class OdometerReminder: Syncable {
    var id: String?
    @Attribute(.unique) var clientId: String = ""
    var vehicleId: String = ""
    var title: String = ""
    var targetOdometer: Int = 0
    var advanceKm: Int = 200
    var notificationMode: String = "reminder"
    var completed: Bool = false
    var synced: Bool = false
    var createdAt: Date?
    var updatedAt: Date?
    var deleted: Bool = false
    var deletedAt: Date?

    init(vehicleId: String, title: String, targetOdometer: Int) {
        clientId = UUID().uuidString
        self.vehicleId = vehicleId
        self.title = title
        self.targetOdometer = targetOdometer
    }

    func isDue(at odometer: Int) -> Bool {
        !deleted && !completed && odometer >= max(0, targetOdometer - advanceKm)
    }

    func applyRemoteChanges(to local: OdometerReminder) {
        local.id = id
        local.title = title
        local.vehicleId = vehicleId
        local.targetOdometer = targetOdometer
        local.advanceKm = advanceKm
        local.notificationMode = notificationMode
        local.completed = completed
        local.createdAt = createdAt
        local.updatedAt = updatedAt
        local.deleted = deleted
        local.deletedAt = deletedAt
        local.synced = true
    }
}

struct OdometerReminderPayload: Codable {
    var id: String?
    var clientId: String
    var vehicleId: String
    var title: String
    var targetOdometer: Int
    var advanceKm: Int
    var notificationMode: String
    var completed: Bool
    var deleted: Bool?
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    init(_ reminder: OdometerReminder) {
        id = reminder.id
        clientId = reminder.clientId
        vehicleId = reminder.vehicleId
        title = reminder.title
        targetOdometer = reminder.targetOdometer
        advanceKm = reminder.advanceKm
        notificationMode = reminder.notificationMode
        completed = reminder.completed
        deleted = reminder.deleted
        deletedAt = reminder.deletedAt
        createdAt = reminder.createdAt
        updatedAt = reminder.updatedAt
    }

    func model() -> OdometerReminder {
        let result = OdometerReminder(vehicleId: vehicleId, title: title, targetOdometer: targetOdometer)
        result.id = id
        result.clientId = clientId
        result.advanceKm = advanceKm
        result.notificationMode = notificationMode
        result.completed = completed
        result.deleted = deleted ?? false
        result.deletedAt = deletedAt
        result.createdAt = createdAt
        result.updatedAt = updatedAt
        result.synced = true
        return result
    }
}

struct OdometerReminderRequest: Encodable {
    let clientId: String
    let vehicleId: String
    let title: String
    let targetOdometer: Int
    let advanceKm: Int
    let notificationMode: String
    let completed: Bool

    init(_ reminder: OdometerReminder) {
        clientId = reminder.clientId
        vehicleId = reminder.vehicleId
        title = reminder.title
        targetOdometer = reminder.targetOdometer
        advanceKm = reminder.advanceKm
        notificationMode = reminder.notificationMode
        completed = reminder.completed
    }
}
