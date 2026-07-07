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
        VehicleService(
            id: id,
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
