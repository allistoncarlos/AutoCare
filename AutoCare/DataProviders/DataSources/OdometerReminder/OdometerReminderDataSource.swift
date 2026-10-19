import Foundation
protocol OdometerReminderDataSourceProtocol { func save(reminder: OdometerReminder) async throws -> OdometerReminderResponse?; func delete(reminder: OdometerReminder) async }
final class OdometerReminderDataSource: OdometerReminderDataSourceProtocol {
    func save(reminder: OdometerReminder) async throws -> OdometerReminderResponse? { await NetworkManager.shared.performRequest(responseType: OdometerReminderResponse.self, endpoint: .saveOdometerReminder(data: reminder.toRequest(), serverId: reminder.id)) }
    func delete(reminder: OdometerReminder) async { _ = await NetworkManager.shared.performRequest(responseType: OdometerReminderResponse.self, endpoint: .deleteOdometerReminder(clientId: reminder.id ?? reminder.clientId)) }
}
