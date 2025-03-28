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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
    }
    
    func toVehicleType() -> VehicleType {
        return VehicleType(
            id: id,
            name: self.name,
            emoji: self.emoji
        )
    }
}
