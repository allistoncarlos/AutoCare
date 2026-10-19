import Factory
import Foundation
protocol OdometerReminderRepositoryProtocol { func fetchData(vehicleId: String) async -> [OdometerReminder]; func save(reminder: OdometerReminder) async -> OdometerReminder?; func delete(reminder: OdometerReminder) async }
struct OdometerReminderRepository: OdometerReminderRepositoryProtocol {
    @Injected(\.odometerReminderDataSource) private var dataSource
    func fetchData(vehicleId: String) async -> [OdometerReminder] { (try? await SwiftDataManager.shared.fetch(where: #Predicate<OdometerReminder> { $0.vehicleId == vehicleId && !$0.deleted }, sortBy: [SortDescriptor(\.targetOdometer)])) ?? [] }
    func save(reminder: OdometerReminder) async -> OdometerReminder? { guard let result = try? await SwiftDataManager.shared.save(id: reminder.id, item: reminder) else { return nil }; BackgroundWorker.shared.run { if let remote = try await dataSource.save(reminder: reminder) { try await SwiftDataManager.shared.updateFromBackend(clientId: remote.clientId ?? remote.id, item: OdometerReminder(id: remote.id, vehicleId: remote.vehicleId, targetOdometer: remote.targetOdometer, notificationDelay: OdometerReminderDelay(rawValue: remote.notificationDelay) ?? .immediate, status: OdometerReminderStatus(rawValue: remote.status) ?? .active, triggeredAt: remote.triggeredAt, triggeredByMileageClientId: remote.triggeredByMileageClientId, clientId: remote.clientId, synced: true)) } }; return result }
    func delete(reminder: OdometerReminder) async { reminder.deleted = true; reminder.deletedAt = .now; reminder.synced = false; _ = await save(reminder: reminder) }
}
