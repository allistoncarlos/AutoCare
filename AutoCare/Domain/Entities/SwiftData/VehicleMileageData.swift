//
//  VehicleMileageData.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 16/02/25.
//

import Foundation
import SwiftData

@Model
final class VehicleMileageData {
    var id: String
    var date: Date = Date()
    var totalCost: Decimal = 0
    var odometer: Int = 0
    var odometerDifference: Int = 0
    var liters: Decimal = 0
    var fuelCost: Decimal = 0
    var calculatedMileage: Decimal = 0
    var complete: Bool = true
    var ownerId: String
    var vehicleId: String

    init(
        id: String,
        date: Date,
        totalCost: Decimal,
        odometer: Int,
        odometerDifference: Int,
        liters: Decimal,
        fuelCost: Decimal,
        calculatedMileage: Decimal,
        complete: Bool,
        ownerId: String,
        vehicleId: String
    ) {
        self.id = id
        self.date = date
        self.totalCost = totalCost
        self.odometer = odometer
        self.odometerDifference = odometerDifference
        self.liters = liters
        self.fuelCost = fuelCost
        self.calculatedMileage = calculatedMileage
        self.complete = complete
        self.ownerId = ownerId
        
        self.vehicleId = vehicleId
    }
}
