//
//  VehicleResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation

struct VehicleResponse: Identifiable, Codable {
    var id: String
    var name: String
    var brand: String
    var model: String
    var year: String
    var licensePlate: String
    var odometer: Int
    var isDefault: Bool
    
    var vehicleType: VehicleTypeResponse
    
    func toVehicle() -> Vehicle {
        return Vehicle(
            id: id,
            name: self.name,
            brand: self.brand,
            model: self.model,
            year: self.year,
            licensePlate: self.licensePlate,
            odometer: self.odometer,
            isDefault: self.isDefault,
            
            vehicleTypeId: self.vehicleType.id
        )
    }
}
