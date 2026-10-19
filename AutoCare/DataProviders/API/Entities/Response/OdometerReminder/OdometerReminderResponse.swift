import Foundation
struct OdometerReminderResponse: Codable { var id: String; var clientId: String?; var vehicleId: String; var targetOdometer: Int; var notificationDelay: String; var status: String; var triggeredAt: Date?; var triggeredByMileageClientId: String?; var createdAt: Date?; var updatedAt: Date?; var deleted: Bool?; var deletedAt: Date? }
