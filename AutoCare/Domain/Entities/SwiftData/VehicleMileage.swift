//
//  VehicleMileage.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 16/02/25.
//

import Foundation
import SwiftData

@Model
final class VehicleMileage: Syncable {
    var id: String? = nil
    var date: Date = Date()
    var totalCost: Decimal = 0
    var odometer: Int = 0
    var odometerDifference: Int = 0
    var liters: Decimal = 0
    var fuelCost: Decimal = 0
    var calculatedMileage: Decimal = 0
    var complete: Bool = true
    var vehicleId: String
    
    var synced: Bool

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
        vehicleId: String,
        
        synced: Bool = false
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
        
        self.synced = synced
    }
    
    public func toRequest() -> VehicleMileageRequest {
        return VehicleMileageRequest(
            id: id,
            date: date,
            totalCost: totalCost,
            odometer: odometer,
            odometerDifference: odometerDifference,
            liters: liters,
            fuelCost: fuelCost,
            calculatedMileage: calculatedMileage,
            complete: complete,
            vehicleId: vehicleId
        )
    }
}
