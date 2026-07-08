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

    var synced: Bool = false
    var clientId: String = ""
    var createdAt: Date?
    var updatedAt: Date?
    var deleted: Bool = false
    var deletedAt: Date?

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
        clientId: String? = nil,
        synced: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deleted: Bool = false,
        deletedAt: Date? = nil
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
        self.clientId = SyncDefaults.resolveClientId(clientId, id: id)
        self.synced = synced
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
        self.deletedAt = deletedAt
    }

    public func toRequest() -> VehicleMileageRequest {
        ensureClientId(from: id)

        return VehicleMileageRequest(
            clientId: clientId,
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
