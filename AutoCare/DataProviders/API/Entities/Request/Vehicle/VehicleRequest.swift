//
//  VehicleRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//

import Foundation

struct VehicleRequest: Codable {
    var clientId: String
    var name: String
    var brand: String
    var model: String
    var year: String
    var licensePlate: String
    var odometer: Int
    var isDefault: Bool
    var vehicleTypeId: String

    init(
        clientId: String,
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        isDefault: Bool,
        vehicleTypeId: String
    ) {
        self.clientId = clientId
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.isDefault = isDefault
        self.vehicleTypeId = vehicleTypeId
    }
}
