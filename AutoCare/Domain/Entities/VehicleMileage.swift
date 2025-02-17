//
//  VehicleMileage.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation
import RealmSwift

protocol SwiftDataConvertible {
    associatedtype Model
    
    func mapToModel() -> Model
}

class VehicleMileage: Object, Identifiable, SwiftDataConvertible {
    typealias Source = VehicleMileage
    typealias Model = VehicleMileageData
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date = Date()
    @Persisted var totalCost: Decimal128 = 0
    @Persisted var odometer: Int = 0
    @Persisted var odometerDifference: Int = 0
    @Persisted var liters: Decimal128 = 0
    @Persisted var fuelCost: Decimal128 = 0
    @Persisted var calculatedMileage: Decimal128 = 0
    @Persisted var complete: Bool = true
    @Persisted var owner_id: String
    @Persisted var vehicle_id: ObjectId

    convenience init(
        date: Date,
        totalCost: Decimal128,
        odometer: Int,
        odometerDifference: Int,
        liters: Decimal128,
        fuelCost: Decimal128,
        calculatedMileage: Decimal128,
        complete: Bool,
        owner_id: String,
        vehicle_id: ObjectId
    ) {
        self.init()
        
        self.date = date
        self.totalCost = totalCost
        self.odometer = odometer
        self.odometerDifference = odometerDifference
        self.liters = liters
        self.fuelCost = fuelCost
        self.calculatedMileage = calculatedMileage
        self.complete = complete
        self.owner_id = owner_id
        
        self.vehicle_id = vehicle_id
    }
    
    func mapToModel() -> VehicleMileageData {
        let mileageId = "\(self._id)"
        
        let vehicleMileageData = VehicleMileageData(
            id: mileageId,
            date: self.date,
            totalCost: self.totalCost.decimalValue,
            odometer: self.odometer,
            odometerDifference: self.odometerDifference,
            liters: self.liters.decimalValue,
            fuelCost: self.fuelCost.decimalValue,
            calculatedMileage: self.calculatedMileage.decimalValue,
            complete: self.complete,
            ownerId: self.owner_id,
            vehicleId: "\(self.vehicle_id)"
        )
        
        return vehicleMileageData
    }
}
