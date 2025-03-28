//
//  VehicleRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//

import Foundation

struct VehicleRequest: Identifiable, Codable {
    var id: String?
    var name: String
    var brand: String
    var model: String
    var year: String
    var licensePlate: String
    var odometer: Int
    var vehicleTypeId: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case model
        case year
        case licensePlate
        case odometer
        case vehicleTypeId
    }
    
    public init(
        id: String?,
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        vehicleTypeId: String
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.vehicleTypeId = vehicleTypeId
    }
}
