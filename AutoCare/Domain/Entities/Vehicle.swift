//
//  Vehicle.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Foundation
import RealmSwift

class Vehicle: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var brand: String = ""
    @Persisted var model: String = ""
    @Persisted var year: String = ""
    @Persisted var licensePlate: String = ""
    @Persisted var odometer: Int = 0
    @Persisted var enabled: Bool = true
    
    @Persisted var vehicleType: VehicleType?
    
    convenience init(
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        vehicleType: VehicleType,
        enabled: Bool = true) {
        self.init()
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.vehicleType = vehicleType
        self.enabled = enabled
    }
}
