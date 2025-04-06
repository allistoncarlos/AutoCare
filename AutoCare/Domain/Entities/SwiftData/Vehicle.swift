//
//  Vehicle.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 16/02/25.
//

import Foundation
import SwiftData

@Model
final class Vehicle: Syncable, Sendable {
    var id: String?
    var name: String = ""
    var brand: String = ""
    var model: String = ""
    var year: String = ""
    var licensePlate: String = ""
    var odometer: Int = 0

    var vehicleTypeId: String
    
    var synced: Bool
    
    init(
        id: String? = nil,
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        vehicleTypeId: String,
        
        synced: Bool = false
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.vehicleTypeId = vehicleTypeId
        
        self.synced = synced
    }
    
    public func toRequest() -> VehicleRequest {
        return VehicleRequest(
            id: id,
            name: name,
            brand: brand,
            model: model,
            year: year,
            licensePlate: licensePlate,
            odometer: odometer,
            vehicleTypeId: vehicleTypeId
        )
    }
}
