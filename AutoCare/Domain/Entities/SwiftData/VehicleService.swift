//
//  VehicleService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation
import SwiftData

@Model
final class VehicleServiceData: Syncable, Sendable {
    var id: String? = nil
    var date: Date = Date()
    var odometer: Int = 0
    var type: String = ""
    var subtype: String = ""
    var totalCost: Decimal = 0
    var comment: String = ""
    var vehicleId: String
    
    var synced: Bool

    init(
        id: String?,
        date: Date,
        odometer: Int,
        type: String,
        subtype: String,
        totalCost: Decimal,
        comment: String,
        vehicleId: String,
        
        synced: Bool = false
    ) {
        self.id = id
        self.date = date
        self.odometer = odometer
        self.type = type
        self.subtype = subtype
        self.totalCost = totalCost
        self.comment = comment
        
        self.vehicleId = vehicleId
        
        self.synced = synced
    }
    
    public func toRequest() -> VehicleServiceRequest {
        return VehicleServiceRequest(
            id: id,
            date: date,
            odometer: odometer,
            type: type,
            subtype: subtype,
            totalCost: totalCost,
            comment: comment,
            vehicleId: vehicleId
        )
    }
    
    public func toVehicleService() -> VehicleService {
        return VehicleService(
            id: id ?? UUID().uuidString,
            date: date,
            odometer: odometer,
            type: VehicleServiceType(rawValue: type) ?? .wheelsAndTyres,
            subtype: VehicleServiceSubtype(rawValue: subtype) ?? .calibrate,
            totalCost: totalCost,
            comment: comment,
            vehicle_id: vehicleId
        )
    }
}

