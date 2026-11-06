import Foundation
import SwiftData

@MainActor
final class OdometerReminderRepository {
    static let shared = OdometerReminderRepository()
    private var pushing = false
    private var context: ModelContext { SwiftDataManager.shared.context }

    func save(_ reminder: OdometerReminder) throws {
        reminder.synced = false
        reminder.updatedAt = .now
        context.insert(reminder)
        try context.save()
        Task { await pushPending() }
    }

    func remove(_ reminder: OdometerReminder) throws {
        reminder.deleted = true
        reminder.deletedAt = .now
        try save(reminder)
        ReminderAlertService.shared.cancel(reminder)
    }

    func setCompleted(_ reminder: OdometerReminder, _ completed: Bool) throws {
        reminder.completed = completed
        try save(reminder)
        if completed { ReminderAlertService.shared.cancel(reminder) }
    }

    func pushPending() async {
        guard !pushing, KeychainDataSource.hasValidToken() else { return }
        pushing = true
        defer { pushing = false }
        do {
            // Repeat if the user changes a reminder while its request is in flight.
            var attempted: [String: Date] = [:]
            while let reminder = try context.fetch(FetchDescriptor<OdometerReminder>())
                .first(where: { !$0.synced && attempted[$0.clientId] != ($0.updatedAt ?? .distantPast) }) {
                let revision = reminder.updatedAt ?? .distantPast
                attempted[reminder.clientId] = revision
                let endpoint: AutoCareAPI = reminder.deleted
                    ? .deleteOdometerReminder(clientId: reminder.clientId)
                    : .saveOdometerReminder(data: OdometerReminderRequest(reminder), serverId: reminder.id)
                if reminder.deleted && reminder.id == nil {
                    // A prior POST may have reached the server without its reply reaching us.
                    // Upsert first, then delete using the stable client ID.
                    let restored = await NetworkManager.shared.performRequest(
                        responseType: OdometerReminderPayload.self,
                        endpoint: .saveOdometerReminder(data: OdometerReminderRequest(reminder), serverId: nil))
                    guard let restored else { continue }
                    reminder.id = restored.id
                }
                guard let response = await NetworkManager.shared.performRequest(
                    responseType: OdometerReminderPayload.self, endpoint: endpoint
                ) else { continue }
                reminder.id = response.id
                if reminder.updatedAt == revision {
                    response.model().applyRemoteChanges(to: reminder)
                }
                try context.save()
            }
        } catch { print("Falha ao sincronizar lembretes: \(error)") }
    }

    func apply(_ incoming: [OdometerReminderPayload]) throws {
        let locals = try context.fetch(FetchDescriptor<OdometerReminder>())
        for payload in incoming {
            let remote = payload.model()
            if let local = locals.first(where: { $0.clientId == payload.clientId }) {
                guard local.synced else { continue }
                remote.applyRemoteChanges(to: local)
                if local.completed || local.deleted { ReminderAlertService.shared.cancel(local) }
            } else if !remote.deleted {
                context.insert(remote)
            }
        }
        try context.save()
    }
}
