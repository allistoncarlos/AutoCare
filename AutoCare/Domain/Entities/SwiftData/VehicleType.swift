//
//  VehicleType.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation
import SwiftData

@Model
final class VehicleType: Syncable {
    var id: String
    var name: String
    var emoji: String

    var synced: Bool = false
    var clientId: String = ""
    var createdAt: Date?
    var updatedAt: Date?
    var deleted: Bool = false
    var deletedAt: Date?

    init(
        id: String,
        name: String,
        emoji: String,
        clientId: String? = nil,
        synced: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deleted: Bool = false,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.clientId = SyncDefaults.resolveClientId(clientId, id: id)
        self.synced = synced
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
        self.deletedAt = deletedAt
    }
}
