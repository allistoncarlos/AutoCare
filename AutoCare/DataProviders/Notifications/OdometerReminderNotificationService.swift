import Foundation
import UserNotifications

final class OdometerReminderNotificationService {
    static let shared = OdometerReminderNotificationService()
    private init() {}

    func requestAuthorization() async { _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) }

    func schedule(reminder: OdometerReminder, vehicleName: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Lembrete de odômetro"
        content.body = "\(vehicleName ?? "Seu veículo") atingiu \(reminder.targetOdometer) km."
        content.sound = .default
        let identifier = reminder.clientId
        let trigger: UNNotificationTrigger? = reminder.notificationDelay.seconds == 0 ? nil : UNTimeIntervalNotificationTrigger(timeInterval: reminder.notificationDelay.seconds, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancel(reminder: OdometerReminder) { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.clientId]) }

    func schedule(reminder: Reminder) {
        guard let dueDate = reminder.dueDate, reminder.status == .pending, dueDate > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.reminderDescription
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: reminder.clientId, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)))
    }

    func cancel(reminder: Reminder) { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.clientId]) }
}
