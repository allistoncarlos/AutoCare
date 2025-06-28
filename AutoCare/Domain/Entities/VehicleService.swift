//
//  VehicleService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import SwiftData

enum VehicleServiceType: String, Codable, CustomStringConvertible {
    case wheelsAndTyres
    
    var description : String {
        switch self {
        case .wheelsAndTyres: return "Rodas e Pneus"
        default: return "Outros"
        }
    }
}

enum VehicleServiceSubtype: String, Codable, CustomStringConvertible {
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

@Model
final class VehicleService: Syncable, Sendable {
    var id: String
    var date: Date = Date()
    var odometer: Int = 0
    var type: VehicleServiceType
    var subtype: VehicleServiceSubtype
    var totalCost: Decimal = 0
    var comment: String = ""
    var vehicle_id: String
    
    var synced: Bool

    init(
        id: String,
        date: Date,
        odometer: Int,
        type: VehicleServiceType,
        subtype: VehicleServiceSubtype,
        totalCost: Decimal,
        comment: String,
        vehicle_id: String,
        
        synced: Bool = false
    ) {
        self.id = id
        self.date = date
        self.odometer = odometer
        self.type = type
        self.subtype = subtype
        self.totalCost = totalCost
        self.comment = comment
        
        self.vehicle_id = vehicle_id
        
        self.synced = synced
    }

    public func toRequest() -> VehicleServiceRequest {
        return VehicleServiceRequest(
            id: id,
            date: date,
            odometer: odometer,
            type: type.rawValue,
            subtype: subtype.rawValue,
            totalCost: totalCost,
            comment: comment,
            vehicleId: vehicle_id
        )
    }
}
