//
//  VehicleServiceRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation

struct VehicleServiceRequest: Codable {
    let id: String?
    let date: Date
    let odometer: Int
    let type: String
    let subtype: String
    let totalCost: Decimal
    let comment: String
    let vehicleId: String
}

