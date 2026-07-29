//
//  Vehicle.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 16/02/25.
//

import Foundation
import SwiftData

@Model
final class Vehicle: Syncable {
    var id: String?
    var name: String = ""
    var brand: String = ""
    var model: String = ""
    var year: String = ""
    var licensePlate: String = ""
    var odometer: Int = 0
    var isDefault: Bool

    var vehicleTypeId: String

    var synced: Bool = false
    @Attribute(.unique) var clientId: String = ""
    var createdAt: Date?
    var updatedAt: Date?
    var deleted: Bool = false
    var deletedAt: Date?

    init(
        id: String? = nil,
        name: String,
        brand: String,
        model: String,
        year: String,
        licensePlate: String,
        odometer: Int,
        isDefault: Bool,
        vehicleTypeId: String,
        clientId: String? = nil,
        synced: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deleted: Bool = false,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.odometer = odometer
        self.isDefault = isDefault
        self.vehicleTypeId = vehicleTypeId
        self.clientId = SyncDefaults.resolveClientId(clientId, id: id)
        self.synced = synced
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
        self.deletedAt = deletedAt
    }

    public func toRequest() -> VehicleRequest {
        ensureClientId(from: id)

        return VehicleRequest(
            clientId: clientId,
            name: name,
            brand: brand,
            model: model,
            year: year,
            licensePlate: licensePlate,
            odometer: odometer,
            isDefault: isDefault,
            vehicleTypeId: vehicleTypeId
        )
    }

    var referenceId: String {
        if let id, !id.isEmpty {
            return id
        }

        return clientId
    }
}
