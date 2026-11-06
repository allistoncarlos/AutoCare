import AlarmKit
import Combine
import Foundation
import SwiftData
import SwiftUI
import UserNotifications

private struct OdometerAlarmMetadata: AlarmMetadata {}

@MainActor
final class ReminderAlertService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderAlertService()
    @Published var errorMessage: String?

    func start() {
        UNUserNotificationCenter.current().delegate = self
    }

    func authorize(_ mode: ReminderNotificationMode) async throws {
        if mode == .alarm {
            guard try await AlarmManager.shared.requestAuthorization() == .authorized else {
                throw AlertError.permission("Permita alarmes do AutoCare em Ajustes para receber este aviso.")
            }
        } else {
            guard try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) else {
                throw AlertError.permission("Permita notificações do AutoCare em Ajustes para receber os lembretes.")
            }
        }
    }

    func evaluate(vehicleId: String, odometer: Int) async {
        do {
            let context = SwiftDataManager.shared.context
            let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
            let vehicle = vehicles.first { $0.id == vehicleId || $0.clientId == vehicleId }
            let references = Set([vehicleId, vehicle?.id, vehicle?.clientId].compactMap { $0 })
            let reminders = try context.fetch(FetchDescriptor<OdometerReminder>())
                .filter { references.contains($0.vehicleId) && $0.isDue(at: odometer) }
            var failed = false
            for reminder in reminders {
                let revision = reminder.updatedAt
                do {
                    if reminder.notificationMode == ReminderNotificationMode.alarm.rawValue {
                        guard AlarmManager.shared.authorizationState == .authorized else {
                            throw AlertError.permission("Há alarmes pendentes. Permita alarmes do AutoCare em Ajustes.")
                        }
                        let attributes = AlarmAttributes(
                            presentation: AlarmPresentation(alert: AlarmPresentation.Alert(
                                title: LocalizedStringResource(stringLiteral: "\(reminder.title) · \(odometer) km"),
                                stopButton: AlarmButton(text: "Parar", textColor: .white, systemImageName: "stop.circle")
                            )),
                            metadata: OdometerAlarmMetadata(), tintColor: .purple
                        )
                        let id = alarmID(reminder)
                        if (try AlarmManager.shared.alarms).contains(where: { $0.id == id }) {
                            try AlarmManager.shared.cancel(id: id)
                        }
                        _ = try await AlarmManager.shared.schedule(id: id, configuration: .alarm(
                            schedule: .fixed(Date().addingTimeInterval(3)), attributes: attributes
                        ))
                    } else {
                        let settings = await UNUserNotificationCenter.current().notificationSettings()
                        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                            throw AlertError.permission("Há lembretes pendentes. Permita notificações do AutoCare em Ajustes.")
                        }
                        guard reminder.isDue(at: odometer), reminder.updatedAt == revision else { continue }
                        let content = UNMutableNotificationContent()
                        content.title = reminder.title
                        content.body = "Odômetro: \(odometer) km. Alvo: \(reminder.targetOdometer) km. Conclua em Lembretes no AutoCare."
                        content.sound = .default
                        content.threadIdentifier = "odometer-\(vehicleId)"
                        try await UNUserNotificationCenter.current().add(UNNotificationRequest(
                            identifier: notificationID(reminder), content: content,
                            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        ))
                    }
                    // Completion or editing can happen while the system schedules an alert.
                    if !reminder.isDue(at: odometer) || reminder.updatedAt != revision {
                        cancel(reminder)
                    }
                } catch {
                    failed = true
                    errorMessage = "Alguns avisos não puderam ser emitidos. \(error.localizedDescription) Os lembretes continuam disponíveis na lista."
                }
            }
            if !failed { errorMessage = nil }
        } catch { errorMessage = "Não foi possível consultar os lembretes: \(error.localizedDescription)" }
    }

    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        // AlarmKit only exposes alarms belonging to this app.
        do {
            for alarm in try AlarmManager.shared.alarms { try AlarmManager.shared.cancel(id: alarm.id) }
        } catch { print("Falha ao cancelar alarmes: \(error)") }
        errorMessage = nil
    }

    func cancel(_ reminder: OdometerReminder) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(reminder)])
        center.removeDeliveredNotifications(withIdentifiers: [notificationID(reminder)])
        let id = alarmID(reminder)
        if (try? AlarmManager.shared.alarms.contains(where: { $0.id == id })) == true {
            do { try AlarmManager.shared.cancel(id: id) }
            catch { errorMessage = "Não foi possível cancelar o alarme: \(error.localizedDescription)" }
        }
    }

    private func notificationID(_ reminder: OdometerReminder) -> String { "odometer-\(reminder.clientId)" }

    private func alarmID(_ reminder: OdometerReminder) -> UUID {
        if let uuid = UUID(uuidString: reminder.clientId) { return uuid }
        let key = "odometer-alarm-\(reminder.clientId)"
        if let value = UserDefaults.standard.string(forKey: key), let uuid = UUID(uuidString: value) { return uuid }
        let uuid = UUID()
        UserDefaults.standard.set(uuid.uuidString, forKey: key)
        return uuid
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    private enum AlertError: LocalizedError {
        case permission(String)
        var errorDescription: String? {
            switch self { case .permission(let message): return message }
        }
    }
}
