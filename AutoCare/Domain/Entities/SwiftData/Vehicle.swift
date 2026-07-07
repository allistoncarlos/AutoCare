//
//  Vehicle.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 16/02/25.
//

import Foundation
import SwiftData

@Model
final class Vehicle: Sendable {
    var id: String?
    var name: String = ""
    var brand: String = ""
    var model: String = ""
    var year: String = ""
    var licensePlate: String = ""
    var odometer: Int = 0
    var isDefault: Bool
    var vehicleTypeId: String

    init(
        id: String? = nil,
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        isDefault: Bool,
        vehicleTypeId: String
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.isDefault = isDefault
        self.vehicleTypeId = vehicleTypeId
    }

    func toRequest() -> VehicleRequest {
        VehicleRequest(
            clientId: id ?? UUID().uuidString,
            name: name,
            brand: brand,
            model: model,
            year: year,
            licensePlate: licensePlate,
            odometer: odometer,
            isDefault: isDefault,
            vehicleTypeId: vehicleTypeId
        )
    }
}
