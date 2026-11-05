import Foundation
protocol ReminderDataSourceProtocol { func save(reminder: Reminder) async throws -> ReminderResponse?; func delete(reminder: Reminder) async }
final class ReminderDataSource: ReminderDataSourceProtocol {
    func save(reminder: Reminder) async throws -> ReminderResponse? { await NetworkManager.shared.performRequest(responseType: ReminderResponse.self, endpoint: .saveReminder(data: reminder.toRequest(), serverId: reminder.id)) }
    func delete(reminder: Reminder) async { _ = await NetworkManager.shared.performRequest(responseType: ReminderResponse.self, endpoint: .deleteReminder(clientId: reminder.id ?? reminder.clientId)) }
}
