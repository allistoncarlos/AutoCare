import Foundation
import SwiftData

enum OdometerReminderDelay: String, Codable, CaseIterable, Identifiable {
    case immediate, fifteenMinutes = "15m", thirtyMinutes = "30m", oneHour = "1h", twoHours = "2h", fourHours = "4h"
    var id: String { rawValue }
    var title: String { switch self { case .immediate: "Na hora"; case .fifteenMinutes: "15 minutos"; case .thirtyMinutes: "30 minutos"; case .oneHour: "1 hora"; case .twoHours: "2 horas"; case .fourHours: "4 horas" } }
    var seconds: TimeInterval { switch self { case .immediate: 0; case .fifteenMinutes: 900; case .thirtyMinutes: 1800; case .oneHour: 3600; case .twoHours: 7200; case .fourHours: 14400 } }
}

enum OdometerReminderStatus: String, Codable { case active, triggered }

@Model final class OdometerReminder: Syncable {
    var id: String?
    var vehicleId: String
    var targetOdometer: Int
    var notificationDelay: OdometerReminderDelay
    var status: OdometerReminderStatus
    var triggeredAt: Date?
    var triggeredByMileageClientId: String?
    var synced = false
    @Attribute(.unique) var clientId = ""
    var createdAt: Date?
    var updatedAt: Date?
    var deleted = false
    var deletedAt: Date?

    init(id: String? = nil, vehicleId: String, targetOdometer: Int, notificationDelay: OdometerReminderDelay, status: OdometerReminderStatus = .active, triggeredAt: Date? = nil, triggeredByMileageClientId: String? = nil, clientId: String? = nil, synced: Bool = false, createdAt: Date? = nil, updatedAt: Date? = nil, deleted: Bool = false, deletedAt: Date? = nil) {
        self.id = id; self.vehicleId = vehicleId; self.targetOdometer = targetOdometer; self.notificationDelay = notificationDelay; self.status = status; self.triggeredAt = triggeredAt; self.triggeredByMileageClientId = triggeredByMileageClientId; self.clientId = SyncDefaults.resolveClientId(clientId, id: id); self.synced = synced; self.createdAt = createdAt; self.updatedAt = updatedAt; self.deleted = deleted; self.deletedAt = deletedAt
    }
    func toRequest() -> OdometerReminderRequest { ensureClientId(from: id); return .init(clientId: clientId, vehicleId: vehicleId, targetOdometer: targetOdometer, notificationDelay: notificationDelay.rawValue, status: status.rawValue, triggeredAt: triggeredAt, triggeredByMileageClientId: triggeredByMileageClientId) }
    convenience init(from response: SyncChangeResponse) { self.init(id: response.id, vehicleId: response.vehicleId ?? "", targetOdometer: response.targetOdometer ?? 0, notificationDelay: OdometerReminderDelay(rawValue: response.notificationDelay ?? "immediate") ?? .immediate, status: OdometerReminderStatus(rawValue: response.reminderStatus ?? "active") ?? .active, triggeredAt: response.triggeredAt, triggeredByMileageClientId: response.triggeredByMileageClientId, clientId: response.clientId, synced: true, updatedAt: response.updatedAt.flatMap { ISO8601DateFormatter().date(from: $0) }, deleted: response.deleted ?? false, deletedAt: response.deletedAt.flatMap { ISO8601DateFormatter().date(from: $0) }) }
    func applyRemoteChanges(to local: OdometerReminder) { local.id = id; local.vehicleId = vehicleId; local.targetOdometer = targetOdometer; local.notificationDelay = notificationDelay; local.status = status; local.triggeredAt = triggeredAt; local.triggeredByMileageClientId = triggeredByMileageClientId; local.synced = true; local.updatedAt = updatedAt; local.deleted = deleted; local.deletedAt = deletedAt }
}
