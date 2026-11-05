import Foundation
import SwiftData

enum ReminderStatus: String, Codable { case pending, completed }

@Model final class Reminder: Syncable {
    var id: String?
    var title: String
    var reminderDescription: String
    var dueDate: Date?
    var status: ReminderStatus
    var completedAt: Date?
    var synced = false
    @Attribute(.unique) var clientId = ""
    var createdAt: Date?
    var updatedAt: Date?
    var deleted = false
    var deletedAt: Date?

    init(id: String? = nil, title: String, reminderDescription: String = "", dueDate: Date? = nil, status: ReminderStatus = .pending, completedAt: Date? = nil, clientId: String? = nil, synced: Bool = false, createdAt: Date? = nil, updatedAt: Date? = nil, deleted: Bool = false, deletedAt: Date? = nil) {
        self.id = id; self.title = title; self.reminderDescription = reminderDescription; self.dueDate = dueDate; self.status = status; self.completedAt = completedAt; self.clientId = SyncDefaults.resolveClientId(clientId, id: id); self.synced = synced; self.createdAt = createdAt; self.updatedAt = updatedAt; self.deleted = deleted; self.deletedAt = deletedAt
    }
    func toRequest() -> ReminderRequest { ensureClientId(from: id); return .init(clientId: clientId, title: title, description: reminderDescription, dueDate: dueDate, status: status.rawValue, completedAt: completedAt) }
    convenience init(from change: SyncChangeResponse) { self.init(id: change.id, title: change.title ?? "", reminderDescription: change.reminderDescription ?? "", dueDate: change.dueDate, status: ReminderStatus(rawValue: change.taskStatus ?? "pending") ?? .pending, completedAt: change.completedAt, clientId: change.clientId, synced: true, deleted: change.deleted ?? false, deletedAt: change.deletedAt.flatMap { ISO8601DateFormatter().date(from: $0) }) }
    func applyRemoteChanges(to local: Reminder) { local.id = id; local.title = title; local.reminderDescription = reminderDescription; local.dueDate = dueDate; local.status = status; local.completedAt = completedAt; local.synced = true; local.deleted = deleted; local.deletedAt = deletedAt }
}
