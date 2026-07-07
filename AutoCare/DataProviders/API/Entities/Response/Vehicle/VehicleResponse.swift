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
        Vehicle(
            id: id,
            name: name,
            brand: brand,
            model: model,
            year: year,
            licensePlate: licensePlate,
            odometer: odometer,
            isDefault: isDefault,
            vehicleTypeId: vehicleType.id
        )
    }
}
