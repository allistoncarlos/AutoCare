//
//  VehicleMileageResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/03/25.
//

import Foundation

struct VehicleMileageResponse: Identifiable, Codable {
    var id: String
    var date: Date = Date()
    var totalCost: Decimal = 0
    var odometer: Int = 0
    var odometerDifference: Int = 0
    var liters: Decimal = 0
    var fuelCost: Decimal = 0
    var calculatedMileage: Decimal = 0
    var complete: Bool = true
    var vehicleId: String
    
    func toVehicleMileage() -> VehicleMileage {
        return VehicleMileage(
            id: id,
            date: self.date,
            totalCost: self.totalCost,
            odometer: self.odometer,
            odometerDifference: self.odometerDifference,
            liters: self.liters,
            fuelCost: self.fuelCost,
            calculatedMileage: self.calculatedMileage,
            complete: self.complete,
            vehicleId: self.vehicleId
        )
    }
}
