import Foundation
struct ReminderResponse: Codable { var id: String; var clientId: String?; var title: String; var description: String; var dueDate: Date?; var status: String; var completedAt: Date?; var createdAt: Date?; var updatedAt: Date?; var deleted: Bool?; var deletedAt: Date? }
