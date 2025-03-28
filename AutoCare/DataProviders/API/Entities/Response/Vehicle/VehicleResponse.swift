//
//  VehicleResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation

struct VehicleResponse: Identifiable, Codable {
    public var id: String
    public var name: String
    public var brand: String
    public var model: String
    public var year: String
    public var licensePlate: String
    public var odometer: Int
    
    public var vehicleType: VehicleTypeResponse

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case model
        case year
        case licensePlate
        case odometer

        case vehicleType
    }
    
    func toVehicle() -> Vehicle {
        return Vehicle(
            id: id,
            name: self.name,
            brand: self.brand,
            model: self.model,
            year: self.year,
            licensePlate: self.licensePlate,
            odometer: self.odometer,
            
            vehicleTypeId: self.vehicleType.id,
            vehicleType: self.vehicleType.name,
            vehicleTypeEmoji: self.vehicleType.emoji
        )
    }
}
