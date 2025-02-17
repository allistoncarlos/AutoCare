//
//  VehicleData.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 16/02/25.
//

import Foundation
import SwiftData

@Model
final class VehicleData {
    var id: String = ""
    var name: String = ""
    var brand: String = ""
    var model: String = ""
    var year: String = ""
    var licensePlate: String = ""
    var odometer: Int = 0
    var enabled: Bool = true
    var ownerId: String
    
    init(
        id: String,
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        enabled: Bool,
        ownerId: String
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.enabled = enabled
        self.ownerId = ownerId
    }
}
