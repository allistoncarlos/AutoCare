import Foundation
struct OdometerReminderRequest: Codable { var clientId: String; var vehicleId: String; var targetOdometer: Int; var notificationDelay: String; var status: String; var triggeredAt: Date?; var triggeredByMileageClientId: String? }
