//
//  VehicleServiceResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation

struct VehicleServiceResponse: Identifiable, Codable {
    var id: String
    var date: Date = Date()
    var odometer: Int = 0
    var type: String = ""
    var subtype: String = ""
    var totalCost: Decimal = 0
    var comment: String = ""
    var vehicleId: String
    
    func toVehicleService() -> VehicleService {
        return VehicleService(
            id: id,
            date: self.date,
            odometer: self.odometer,
            type: VehicleServiceType(rawValue: type) ?? .wheelsAndTyres,
            subtype: VehicleServiceSubtype(rawValue: subtype) ?? .calibrate,
            totalCost: self.totalCost,
            comment: self.comment,
            vehicle_id: self.vehicleId
        )
    }
}

