//
//  VehicleMileageRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/03/25.
//

import Foundation

struct VehicleMileageRequest: Identifiable, Codable {
    var id: String?
    var date: Date
    var totalCost: Decimal
    var odometer: Int
    var odometerDifference: Int
    var liters: Decimal
    var fuelCost: Decimal
    var calculatedMileage: Decimal
    var complete: Bool
    var vehicleId: String

    init(
        id: String?,
        date: Date,
        totalCost: Decimal,
        odometer: Int,
        odometerDifference: Int,
        liters: Decimal,
        fuelCost: Decimal,
        calculatedMileage: Decimal,
        complete: Bool,
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
        
        self.vehicleId = vehicleId
    }
}
