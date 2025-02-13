//
//  VehicleService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import RealmSwift

enum VehicleServiceType: String, PersistableEnum {
    case wheelsAndTyres
}

enum VehicleServiceSubtype: String, PersistableEnum {
    case calibration
    case flatTyre
    case newTyres
}

class VehicleService: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date = Date()
    @Persisted var odometer: Int = 0
    @Persisted var serviceType: VehicleServiceType
    @Persisted var subtype: VehicleServiceSubtype
    @Persisted var totalCost: Decimal128 = 0
    @Persisted var comment: String = ""
    @Persisted var owner_id: String
    @Persisted var vehicle_id: ObjectId

    convenience init(
        date: Date,
        odometer: Int,
        serviceType: VehicleServiceType,
        subtype: VehicleServiceSubtype,
        totalCost: Decimal128,
        comment: String,
        owner_id: String,
        vehicle_id: ObjectId
    ) {
        self.init()
        
        self.date = date
        self.odometer = odometer
        self.serviceType = serviceType
        self.subtype = subtype
        self.totalCost = totalCost
        self.comment = comment
        self.owner_id = owner_id
        
        self.vehicle_id = vehicle_id
    }
}
