//
//  VehicleService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import SwiftData

enum VehicleServiceType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case wheelsAndTyres
    case wash
    case repair

    var id: String { rawValue }

    var description: String {
        switch self {
        case .wheelsAndTyres: return "Rodas e Pneus"
        case .wash: return "Lavagem"
        case .repair: return "Reparo"
        }
    }

    var systemImage: String {
        switch self {
        case .wheelsAndTyres: return "circle.circle"
        case .wash: return "drop.fill"
        case .repair: return "wrench.and.screwdriver.fill"
        }
    }

    var subtypes: [VehicleServiceSubtype] {
        switch self {
        case .wheelsAndTyres:
            return [.calibrate, .flatTyre, .newTyres]
        case .wash:
            return [.simpleWash, .completeWash]
        case .repair:
            return [.lamps, .wrecks, .windows]
        }
    }
}

enum VehicleServiceSubtype: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case calibrate
    case flatTyre
    case newTyres
    case simpleWash
    case completeWash
    case lamps
    case wrecks
    case windows

    var id: String { rawValue }

    var description: String {
        switch self {
        case .calibrate: return "Calibragem"
        case .flatTyre: return "Pneu Furado"
        case .newTyres: return "Novos Pneus"
        case .simpleWash: return "Simples"
        case .completeWash: return "Completa"
        case .lamps: return "Lâmpadas"
        case .wrecks: return "Amassados"
        case .windows: return "Vidros"
        }
    }
}

@Model
final class VehicleService: Syncable {
    var id: String?
    var date: Date = Date()
    var odometer: Int = 0
    var type: VehicleServiceType
    var subtype: VehicleServiceSubtype
    var totalCost: Decimal = 0
    var comment: String = ""
    var vehicle_id: String

    var synced: Bool = false
    @Attribute(.unique) var clientId: String = ""
    var createdAt: Date?
    var updatedAt: Date?
    var deleted: Bool = false
    var deletedAt: Date?

    init(
        id: String? = nil,
        date: Date,
        odometer: Int,
        type: VehicleServiceType,
        subtype: VehicleServiceSubtype,
        totalCost: Decimal,
        comment: String,
        vehicle_id: String,
        clientId: String? = nil,
        synced: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deleted: Bool = false,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.odometer = odometer
        self.type = type
        self.subtype = subtype
        self.totalCost = totalCost
        self.comment = comment
        self.vehicle_id = vehicle_id
        self.clientId = SyncDefaults.resolveClientId(clientId, id: id)
        self.synced = synced
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
        self.deletedAt = deletedAt
    }

    public func toRequest() -> VehicleServiceRequest {
        ensureClientId(from: id)

        return VehicleServiceRequest(
            clientId: clientId,
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
