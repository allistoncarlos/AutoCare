//
//  ChangesResponse.swift
//  AutoCare
//

import Foundation

struct SyncChangeResponse: Codable {
    var id: String?
    var clientId: String?
    var updatedAt: String?
    var deleted: Bool?
    var deletedAt: String?

    var name: String?
    var brand: String?
    var model: String?
    var year: String?
    var licensePlate: String?
    var odometer: Int?
    var isDefault: Bool?
    var vehicleTypeId: String?
    var emoji: String?

    var date: Date?
    var totalCost: Decimal?
    var odometerDifference: Int?
    var liters: Decimal?
    var fuelCost: Decimal?
    var calculatedMileage: Decimal?
    var complete: Bool?
    var vehicleId: String?

    var type: String?
    var subtype: String?
    var comment: String?
}

struct ChangesPayloadResponse: Codable {
    var vehicleTypes: [SyncChangeResponse]?
    var vehicles: [SyncChangeResponse]?
    var vehicleMileages: [SyncChangeResponse]?
    var vehicleServices: [SyncChangeResponse]?
}

struct ChangesResponse: Codable {
    var serverTime: String
    var changes: ChangesPayloadResponse
}
