//
//  VehicleService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import RealmSwift

enum VehicleServiceType: String, CustomStringConvertible, PersistableEnum {
    case wheelsAndTyres
    
    var description : String {
        switch self {
        case .wheelsAndTyres: return "Rodas e Pneus"
        default: return "Outros"
        }
    }
}

enum VehicleServiceSubtype: String, CustomStringConvertible, PersistableEnum {
    case calibrate
    case flatTyre
    case newTyres
    
    var description : String {
        switch self {
        case .calibrate: return "Calibragem"
        case .flatTyre: return "Pneu Furado"
        case .newTyres: return "Novos Pneus"
        default: return "Outros"
        }
    }
}

class VehicleService: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date = Date()
    @Persisted var odometer: Int = 0
    @Persisted var type: VehicleServiceType
    @Persisted var subtype: VehicleServiceSubtype
    @Persisted var totalCost: Decimal128 = 0
    @Persisted var comment: String = ""
    @Persisted var owner_id: String
    @Persisted var vehicle_id: ObjectId

    convenience init(
        date: Date,
        odometer: Int,
        type: VehicleServiceType,
        subtype: VehicleServiceSubtype,
        totalCost: Decimal128,
        comment: String,
        owner_id: String,
        vehicle_id: ObjectId
    ) {
        self.init()
        
        self.date = date
        self.odometer = odometer
        self.type = type
        self.subtype = subtype
        self.totalCost = totalCost
        self.comment = comment
        self.owner_id = owner_id
        
        self.vehicle_id = vehicle_id
    }
}
