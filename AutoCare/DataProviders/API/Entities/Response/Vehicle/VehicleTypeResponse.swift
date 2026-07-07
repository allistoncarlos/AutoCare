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

    func toVehicleType() -> VehicleType {
        VehicleType(id: id, name: name, emoji: emoji)
    }
}
