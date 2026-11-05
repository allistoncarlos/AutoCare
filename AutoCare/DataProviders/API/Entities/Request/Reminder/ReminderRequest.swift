import Foundation
struct ReminderRequest: Codable { var clientId: String; var title: String; var description: String; var dueDate: Date?; var status: String; var completedAt: Date? }
