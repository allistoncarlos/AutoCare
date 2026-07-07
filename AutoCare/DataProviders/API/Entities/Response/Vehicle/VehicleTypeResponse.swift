//
//  VehicleTypeResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/03/25.
//

import Foundation

struct VehicleTypeResponse: Codable {
    var id: String
    var name: String
    var emoji: String
    var clientId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var deleted: Bool?
    var deletedAt: Date?

    func toVehicleType() -> VehicleType {
        VehicleType(
            id: id,
            name: name,
            emoji: emoji,
            clientId: clientId ?? id,
            synced: true,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted ?? false,
            deletedAt: deletedAt
        )
    }
}
