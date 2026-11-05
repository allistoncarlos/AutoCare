import Factory
import Foundation
protocol ReminderRepositoryProtocol { func fetchData() async -> [Reminder]; func save(reminder: Reminder) async -> Reminder?; func delete(reminder: Reminder) async }
struct ReminderRepository: ReminderRepositoryProtocol {
    @Injected(\.reminderDataSource) private var dataSource
    func fetchData() async -> [Reminder] { (try? await SwiftDataManager.shared.fetch(where: #Predicate<Reminder> { !$0.deleted }, sortBy: [SortDescriptor(\.status.rawValue), SortDescriptor(\.dueDate)])) ?? [] }
    func save(reminder: Reminder) async -> Reminder? { guard let result = try? await SwiftDataManager.shared.save(id: reminder.id, item: reminder) else { return nil }; BackgroundWorker.shared.run { if let remote = try await dataSource.save(reminder: reminder) { let local = Reminder(id: remote.id, title: remote.title, reminderDescription: remote.description, dueDate: remote.dueDate, status: ReminderStatus(rawValue: remote.status) ?? .pending, completedAt: remote.completedAt, clientId: remote.clientId, synced: true, createdAt: remote.createdAt, updatedAt: remote.updatedAt, deleted: remote.deleted ?? false, deletedAt: remote.deletedAt); try await SwiftDataManager.shared.updateFromBackend(clientId: local.clientId, item: local) } }; return result }
    func delete(reminder: Reminder) async { reminder.deleted = true; reminder.deletedAt = .now; reminder.synced = false; _ = await save(reminder: reminder) }
}
